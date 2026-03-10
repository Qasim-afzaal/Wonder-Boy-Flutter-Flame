# Game Architecture – What Each Part Does

## Separation: character vs logic

- **Character** (`lib/actor/character.dart`) = **appearance only**: sprite paths, frame counts, loading images, building animations. No movement or input.
- **Player** (`lib/actor/player.dart`) = **logic only**: position, velocity, gravity, input, ground, direction, which animation state to show. No sprite paths or frame data.

Level creates `Player(character: Character.from(PlayerCharacter.ninjaFrog))`; Player uses the Character in `onLoad()` to get its animations, then only updates position/state.

---

## File structure (one component per file)

See **CONCEPTS.md** for what position, velocity, gravity, Vector2, scale, groundY, etc. mean and how they are used.

| File | Contains |
|------|----------|
| **lib/main.dart** | App entry: `main()`, fullscreen/landscape, `runApp(GameWidget(game: MyGame()))`. |
| **lib/game/my_game.dart** | `MyGame` (FlameGame), `createWorldAndCamera()`, `worldAndCamera`, `startLevelId`. |
| **lib/levels/level.dart** | `Level` (World): loads Tiled map, spawns Player from object layer (passes Character). |
| **lib/actor/player.dart** | `Player` component: movement, gravity, input, animation state. **Logic only**; appearance from Character. |
| **lib/actor/character.dart** | `Character`: sprite paths, frame data, loadImages(), buildAnimations(), presets (ninjaFrog, pinkMan, etc.). **Appearance only**. |
| **lib/actor/player_state.dart** | `PlayerState` enum (idle, running, jumping, etc.). |
| **lib/actor/player_direction.dart** | `PlayerDirection` enum (left, right). |
| **lib/actor/player_character.dart** | `PlayerCharacter` enum (ninjaFrog, pinkMan, etc.); used with `Character.from()`. |

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

## 4. `actor/player.dart` – Player logic (movement, input, state)

| What | Role |
|------|------|
| **Player** | Extends **SpriteAnimationGroupComponent**; uses **HasGameReference<MyGame>** for `game.images`. **Logic only**: position, velocity, gravity, input, groundY, direction, and which animation state is current. |
| **Character** | Passed in constructor (e.g. `Character.ninjaFrog()` or `Character.from(PlayerCharacter.ninjaFrog)`). Player does not know sprite paths or frame counts; it calls `character.loadImages()` and `character.buildAnimations()` in `onLoad()` and then only sets `current` to a PlayerState. |

**Player responsibilities**

- **Position** – Set in constructor; updated each frame by `position += velocity * dt`.
- **Velocity** – Updated by input (left/right), jump, and gravity; then applied to position.
- **groundY** – Set by Level (e.g. bottom of map); used to land and allow jump again.
- **Direction** – Left/right from input; applied as `scale.x = ±1`.
- **Animation state** – Chooses `current` (idle, running, jumping, falling) from velocity; the actual sprites come from the **Character**'s built animations.

**What Player does not do**

- Does not store sprite paths, frame counts, or texture size; those live in **Character**.
- Does not build SpriteAnimation by hand; Character does that.

---

## 5. `actor/character.dart` – Character appearance (sprites, animations)

| What | Role |
|------|------|
| **Character** | Holds basePath, textureSize, stepTime, and a map of PlayerState → (file, frames). |
| **loadImages(images)** | Loads all sprite sheets for this character into Flame's image cache. |
| **buildAnimations(images)** | Returns Map<PlayerState, SpriteAnimation>; used by Player to fill its `animations` and set `current`. |
| **Presets** | `Character.ninjaFrog()`, `pinkMan()`, `virtualGuy()`, `maskDude()`. |
| **Character.from(PlayerCharacter)** | Returns the matching Character for the enum (e.g. for Level: `Character.from(PlayerCharacter.ninjaFrog)`). |

**When adding a new character** – Add a preset in Character (and optionally a value in PlayerCharacter enum), then in Level use `Player(character: Character.from(PlayerCharacter.newValue))` or `Character.newPreset()`.

---

## 6. `actor/player_*.dart` – Player enums (state, direction, character)

| File | Role |
|------|------|
| **player_state.dart** | `PlayerState` enum: which animation (idle, run, jump, fall, etc.). |
| **player_direction.dart** | `PlayerDirection` enum: left / right (for sprite flip). |
| **player_character.dart** | `PlayerCharacter` enum: which preset (Ninja Frog, Pink Man, etc.); use with `Character.from()`. |

---

## 7. Flame component types (quick reference)

| Component | Purpose |
|-----------|--------|
| **FlameGame** | Root. Has camera, world, game loop, image/sound caches. |
| **World** | Container for “everything in the level” (map, player, enemies). The camera renders this. |
| **CameraComponent** | Defines what part of the world is visible (viewport) and how it’s transformed (viewfinder, scale). |
| **TiledComponent** | Renders a Tiled map (`.tmx` + tilesets). |
| **SpriteAnimationGroupComponent** | Renders one of several **SpriteAnimation**s and can switch between them (e.g. by setting `current` to a different state). |
| **PositionComponent** | Base for anything that has a position (and scale, angle). Player and many others extend this. |

---

## 8. Where to put new logic

- **New level / new map** – New class like `Level` (or same class with different map path), load different `.tmx`, add to world.
- **New spawn type** – In Level’s object loop, add another `case 'Enemy': add(Enemy(position: ...));`.
- **Player movement / input** – In **Player**: already in `update(dt)` via _applyInput, _applyGravity, _applyMovement, _applyGround, _updateDirection, _updateAnimationState.
- **New character** – Add a preset in **Character** (and optionally to **PlayerCharacter**); in Level use `Player(character: Character.from(PlayerCharacter.pinkMan))` or `Character.pinkMan()`.
- **New animation state** – Add a state to **PlayerState**, add an entry in **Character** animationData (and in each preset that needs it), and set `current` from Player logic (e.g. in _updateAnimationState).
