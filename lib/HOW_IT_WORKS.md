# How the game works – step by step

Each main piece of the game lives in its own file:

- **lib/main.dart** – app entry (`main()`)
- **lib/game/my_game.dart** – `MyGame`, level/camera setup
- **lib/levels/level.dart** – `Level` (map + spawns)
- **lib/actor/player.dart** – `Player` (movement, gravity, animations)
- **lib/actor/player_state.dart** – `PlayerState` enum
- **lib/actor/player_direction.dart** – `PlayerDirection` enum
- **lib/actor/player_character.dart** – `PlayerCharacter` enum

---

## 1. App starts (`main.dart`)

```
main()  →  runApp(GameWidget(game: MyGame()))
```

- **GameWidget** is a Flutter widget. It draws the game and calls `MyGame` every frame.
- **MyGame()** is created once. Its constructor does:  
  `super(world: _worldAndCamera.$1, camera: _worldAndCamera.$2)`  
  So Flame gets:
  - **world** = our Level (the “scene”)
  - **camera** = what part of the world we see on screen

**Where do world and camera come from?**

- In **lib/game/my_game.dart**, `createWorldAndCamera(startLevelId)` is called once (when the game is first created).
- It creates:
  1. **Level(levelId: 'lvl-01')** – empty for now; it will load the map and player in its `onLoad()`.
  2. **CameraComponent(..., world: that Level)** – “this camera looks at this level”.
- The result is stored in `worldAndCamera`. So we have one Level and one Camera, and we pass them into `FlameGame`.

---

## 2. Game is ready → `MyGame.onLoad()`

- Runs **once** when the game is ready.
- **images.loadAllImages()** – loads every image under `assets/images/` into a cache.  
  Later, when the Player loads its sprites, it uses paths like `Main Characters/Ninja Frog/Idle (32x32).png`; those files are already in the cache.
- **camera.viewfinder.anchor = Anchor.topLeft** – (0, 0) on screen is the top‑left of the camera view.

---

## 3. Level loads (`level.dart`)

The **Level** is already part of the game (we passed it as `world`). When Flame starts the game, it runs **Level.onLoad()** once.

**Step 1 – Load the map**

- `TiledComponent.load('lvl-01.tmx', Vector2.all(16))` loads the Tiled map.
- Each tile is 16×16 pixels.
- **add(_tileMap)** – the map is added to the Level, so it’s drawn (behind everything else we add).

**Step 2 – Spawn the player**

- The map has an **object layer** named `SponPlayer` (you set this in Tiled).
- On that layer you place objects and set their **class** to `Player`.
- We loop over those objects. For each one with `class_ == 'Player'`:
  - **position** = (object.x, object.y) from Tiled → where the player spawns.
  - **player.groundY** = map height in pixels (e.g. 23 tiles × 16 = 368). So when the player’s Y position reaches 368, we treat them as “on the ground” and stop them falling.
  - **add(player)** – the player is added to the Level, so it’s drawn and its `update()` is called every frame.

So: **Level** = map + player (and later enemies, etc.). The **camera** looks at this Level and draws it on screen.

---

## 4. Player appears and loads sprites (`player.dart`)

When we **add(player)** to the Level, Flame runs **Player.onLoad()** once.

- Loads the Ninja Frog sprite sheets (Idle, Run, Jump, Fall, etc.) into memory (or uses the cache).
- Builds one **SpriteAnimation** per **PlayerState** (idle, running, jumping, falling, …) and stores them in **animations**.
- **current = PlayerState.idle** – so the idle animation is shown first.
- **anchor = Anchor.bottomCenter** – the player’s position is at the **feet**, so when we set position.y = groundY, the feet sit on the ground.

After this, the player is visible and standing at the spawn point. Every frame, **Player.update(dt)** is called.

---

## 5. Every frame – `Player.update(dt)` (the game loop)

`dt` = time since last frame (e.g. 0.016 seconds). We use it so movement is “per second”, not “per frame”.

**Order of what we do each frame:**

1. **Read keyboard**  
   Which keys are pressed? Left/A, Right/D, Jump/Space/Up/W.

2. **Horizontal movement**  
   - Left → `velocity.x = -moveSpeed` (e.g. -200), `direction = left`.  
   - Right → `velocity.x = moveSpeed` (e.g. 200), `direction = right`.  
   - Neither → `velocity.x = 0`.

3. **Jump**  
   - If jump key is pressed **and** `isOnGround` (we define that as `velocity.y >= 0`), set  
     `velocity.y = jumpSpeed` (e.g. -380, so the player goes up).  
   - So you can only “start” a jump when you’re not moving upward (we consider that “on ground” for this simple check).

4. **Gravity**  
   - Every frame we do:  
     `velocity.y += gravity * dt`  
   - So velocity.y increases downward (e.g. +800×0.016 ≈ +12.8 per frame).  
   - That’s why the player goes up when you jump, then slows down, then falls.

5. **Move position**  
   - `position += velocity * dt`  
   - So:
     - **velocity.x** moves the player left/right.
     - **velocity.y** moves the player up/down.

6. **Ground (floor)**  
   - If **groundY** is set (Level set it to the bottom of the map) and **position.y >= groundY**:
     - We clamp: `position.y = groundY`
     - We stop falling: `velocity.y = 0`  
   - So the player “lands” and can jump again.

7. **Direction → sprite flip**  
   - `scale.x = direction == right ? 1 : -1`  
   - So when facing left we draw the sprite mirrored (flip horizontally).

8. **Which animation to play**  
   - **velocity.y < 0** → moving up → **jumping**  
   - **velocity.y > 0** → moving down → **falling**  
   - **velocity.y == 0** and **velocity.x != 0** → **running**  
   - **velocity.y == 0** and **velocity.x == 0** → **idle**

So in one sentence: **each frame we read input, change velocity (gravity + jump + left/right), move position, clamp to ground, flip sprite by direction, and pick the animation from velocity.**

---

## 6. How it looks on screen

- **Camera** looks at the **World** (our Level).
- The **Level** contains:
  - **TiledComponent** (the map) – drawn first.
  - **Player** – drawn on top.
- The camera draws whatever is in the world at the current positions. So when **position** and **scale.x** (and **current** animation) change in **update()**, the next frame shows the player in the new place, facing the right way, with the right animation.

---

## Quick reference

| What            | Where        | When        |
|-----------------|-------------|------------|
| Create Level + Camera | main.dart  | Once at start |
| Load images     | MyGame.onLoad() | Once |
| Load map + spawn player | Level.onLoad() | Once |
| Load sprites + build animations | Player.onLoad() | Once |
| Input, gravity, move, direction, animation | Player.update(dt) | Every frame |

If you want to change how the player moves, change **Player.update()**. If you want to change where the player spawns or the floor height, change **Level** (spawn object position and **groundY**).
