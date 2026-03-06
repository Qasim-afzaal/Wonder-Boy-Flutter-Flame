# Game Architecture – What Each Part Does

## File structure (one component per file)

See **CONCEPTS.md** for what position, velocity, gravity, Vector2, scale, groundY, etc. mean and how they are used.

| File | Contains |
|------|----------|
| **lib/main.dart** | App entry: `main()`, fullscreen/landscape, `runApp(GameWidget(game: MyGame()))`. |
| **lib/game/my_game.dart** | `MyGame` (FlameGame), `createWorldAndCamera()`, `worldAndCamera`, `startLevelId`. |
| **lib/levels/level.dart** | `Level` (World): loads Tiled map, spawns Player from object layer. |
| **lib/actor/player.dart** | `Player` component: movement, gravity, input, animations. |
| **lib/actor/player_state.dart** | `PlayerState` enum (idle, running, jumping, etc.). |
| **lib/actor/player_direction.dart** | `PlayerDirection` enum (left, right). |
| **lib/actor/player_character.dart** | `PlayerCharacter` enum (ninjaFrog, pinkMan, etc.). |

---

## High-level flow

```
main()  →  GameWidget(game: MyGame())
              ↓
         MyGame (FlameGame)
              ↓  has
         CameraComponent  →  viewfinder (what you see on screen)
              ↓  looks at
         World = Level
              ↓  contains
         TiledComponent (map)  +  Player (and later: enemies, items)
```

---

## 1. `main.dart` – App entry only

| What | Role |
|------|------|
| **main()** | Starts the app: initializes Flutter, sets fullscreen/landscape on mobile, runs the game via `GameWidget(game: MyGame())`. |

`MyGame` and game setup live in **lib/game/my_game.dart**.

---

## 2. `game/my_game.dart` – Root game (FlameGame)

| What | Role |
|------|------|
| **startLevelId** | Which level to load (e.g. 'lvl-01'). |
| **createWorldAndCamera()** | Builds one Level and one Camera viewing it. |
| **worldAndCamera** | Result of createWorldAndCamera, used once by MyGame. |
| **MyGame** | Root game class. Passes world and camera to FlameGame, loads images in onLoad(), sets camera anchor. |

---

## 3. `levels/level.dart` – One level (map + entities)

| What | Role |
|------|------|
| **Level** | Extends **World**. A World is the “scene” the camera looks at: the level content. |
| **_tileMap (TiledComponent)** | The level map: tiles, layers, loaded from a `.tmx` file (Tiled). Drawn first so it’s behind the player. |
| **Object layer 'SponPlayer'** | Tiled object layer where you place spawn points. Each object can have a **class** (e.g. `Player`). We read `object.x`, `object.y` and create a **Player** at that position. |

**Level responsibilities**

- Load the Tiled map (`lvl-01.tmx`) with a given tile size (e.g. 16).
- Add the map to the world so it’s drawn.
- Read the spawn object layer and add a **Player** at each `Player` object’s position (and later: enemies, items from other classes).

**Component order**

- `add(_tileMap)` first → map is drawn first (back).
- `add(Player(...))` after → player is drawn on top.

---

## 4. `actor/player.dart` – The player character

| What | Role |
|------|------|
| **PlayerState** | Enum: idle, running, jumping, falling, etc. Used to choose which animation plays and for game logic (e.g. “can jump only when not dead”). |
| **PlayerCharacter** | Enum of preset asset paths (Ninja Frog, Pink Man, etc.). Used in the constructor to choose which character’s sprites to load. |
| **Player** | Extends **SpriteAnimationGroupComponent**: one component that can show different sprite animations and switch between them (e.g. idle vs run). **HasGameRef<MyGame>** gives access to the game (e.g. to use `gameRef.images`). |

**Player responsibilities**

- **Position** – Set in constructor via `super(position: ...)`. Where the player spawns or is placed in the world.
- **Character** – Which sprite folder to use (e.g. Ninja Frog). Decides `_basePath` for loading images.
- **Animations** – In `onLoad()`: load the sprite sheets for that character, then build one **SpriteAnimation** per **PlayerState** (idle, run, jump, etc.) and fill the `animations` map. Set `current = PlayerState.idle` so the right animation is shown.
- **buildSequenceAnimation()** – Generic helper: given path, frame count, step time, and texture size, builds a single **SpriteAnimation** from a row of frames. Used for every state; reusable for other characters or sprites.

**Logic split**

- **Level** – *where* the player is created (position from Tiled, which character to use).
- **Player** – *how* it looks (which sprites, which animation per state) and *how* animations are built (generic sequence builder). Gameplay logic (movement, jump, state changes) would go in **Player** later (e.g. in `update(dt)` or input handlers).

---

## 5. `actor/player_*.dart` – Player enums (state, direction, character)

| File | Role |
|------|------|
| **player_state.dart** | `PlayerState` enum: which animation (idle, run, jump, fall, etc.). |
| **player_direction.dart** | `PlayerDirection` enum: left / right (for sprite flip). |
| **player_character.dart** | `PlayerCharacter` enum: which sprite set (Ninja Frog, Pink Man, etc.). |
| **player.dart** | `Player` component: position, velocity, gravity, input, animations. |

---

## 6. Flame component types (quick reference)

| Component | Purpose |
|-----------|--------|
| **FlameGame** | Root. Has camera, world, game loop, image/sound caches. |
| **World** | Container for “everything in the level” (map, player, enemies). The camera renders this. |
| **CameraComponent** | Defines what part of the world is visible (viewport) and how it’s transformed (viewfinder, scale). |
| **TiledComponent** | Renders a Tiled map (`.tmx` + tilesets). |
| **SpriteAnimationGroupComponent** | Renders one of several **SpriteAnimation**s and can switch between them (e.g. by setting `current` to a different state). |
| **PositionComponent** | Base for anything that has a position (and scale, angle). Player and many others extend this. |

---

## 7. Where to put new logic

- **New level / new map** – New class like `Level` (or same class with different map path), load different `.tmx`, add to world.
- **New spawn type** – In Level’s object loop, add another `case 'Enemy': add(Enemy(position: ...));`.
- **Player movement / input** – In **Player**: override `update(dt)`, read input (e.g. from `gameRef.keyboard` or a custom input manager), change `position` and set `current = PlayerState.running` (or jump, fall, etc.).
- **New character** – Add a new value to **PlayerCharacter** with the right path; use it in Level when creating `Player(character: PlayerCharacter.pinkMan)`.
- **New animation state** – Add a state to **PlayerState**, add an entry in **Player**’s `animationData` map, and set `current` from your movement/logic.
