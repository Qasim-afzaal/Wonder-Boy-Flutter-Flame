# Game concepts – position, velocity, gravity, etc.

Plain-language explanation of the main terms used in the code.

**Architecture:** Appearance (sprites, animations) lives in **Character** (`lib/actor/character.dart`); movement and input logic live in **Player** (`lib/actor/player.dart`). See ARCHITECTURE.md.

---

## Position (`position` / `Vector2`)

- **What it is:** Where the player (or any object) is in the world, in **pixels**.
- **Type:** `Vector2` = two numbers: `x` (horizontal) and `y` (vertical).
- **Coordinate system:**
  - `x` increases to the **right**, `x = 0` is the left edge of the level.
  - `y` increases **downward**, `y = 0` is the **top** of the level.
- **Use:** The camera draws the player at `position`. When we change `position.x` or `position.y`, the player moves on screen.
- **Example:** `position = Vector2(100, 200)` means 100 pixels from the left, 200 pixels from the top.

---

## Velocity (`velocity` / `Vector2`)

- **What it is:** How fast the player is moving **per second**, in **pixels per second**.
- **Type:** `Vector2`: `velocity.x` = horizontal speed, `velocity.y` = vertical speed.
- **Meaning:**
  - `velocity.x > 0` → moving right; `velocity.x < 0` → moving left; `velocity.x == 0` → not moving horizontally.
  - `velocity.y > 0` → moving down (falling); `velocity.y < 0` → moving up (jumping); `velocity.y == 0` → not moving vertically.
- **Use:** Each frame we do `position += velocity * dt`. So velocity is the “speed” that updates position over time. Gravity and input change velocity; then we move position by that velocity.
- **Example:** `velocity = Vector2(200, 0)` → moving 200 px/s to the right. `velocity = Vector2(0, -380)` → moving 380 px/s upward (jump).

---

## Gravity (`gravity`)

- **What it is:** A constant **downward acceleration** in **pixels per second per second** (e.g. 800).
- **Use:** Every frame we do `velocity.y += gravity * dt`. So each second we add 800 to `velocity.y`, making the player fall faster and faster until they hit the ground.
- **Why:** So jumps go up, slow down, then fall down like in real life.

---

## Ground / floor (`groundY`)

- **What it is:** The **y coordinate** (in pixels) where the “floor” is. The player’s feet (anchor is bottom-center) sit at `position.y`.
- **Use:** When `position.y >= groundY`, we set `position.y = groundY` and `velocity.y = 0` so the player stops falling and can jump again.
- **Example:** If the map is 23 tiles × 16 px tall, `groundY = 368` is the bottom of the map.

---

## Direction (`direction` / `PlayerDirection`)

- **What it is:** Which way the sprite is facing: **left** or **right**.
- **Use:** We set `scale.x = 1` (right) or `scale.x = -1` (left) so the same sprite is drawn mirrored when moving the other way. No new art needed.

---

## Scale (`scale` / `Vector2`)

- **What it is:** How much to stretch or flip the sprite. `scale.x` = horizontal scale, `scale.y` = vertical scale.
- **Use:** We only use `scale.x`: `1` = normal (facing right), `-1` = mirrored (facing left). So the player “turns” without a separate left-facing image.

---

## Delta time (`dt`)

- **What it is:** Time in **seconds** since the last frame (e.g. 0.016 for ~60 FPS).
- **Use:** We multiply velocity and movement by `dt` so motion is “per second” and looks the same at 30 FPS or 60 FPS. Example: `position += velocity * dt`.

---

## Anchor (`anchor`)

- **What it is:** Which point of the sprite is at `position` (e.g. center, top-left, bottom-center).
- **Use:** We use `Anchor.bottomCenter` so `position` is at the player’s **feet**. That way when we set `position.y = groundY`, the feet line up with the floor.

---

## Summary

| Term       | Meaning                          | Main use in code                    |
|-----------|-----------------------------------|-------------------------------------|
| **position** | Where the player is (x, y in px) | Drawn at this point; we add velocity×dt to it. |
| **velocity** | Speed per second (x, y in px/s)  | Updated by input + gravity; then added to position. |
| **gravity**  | Downward acceleration (px/s²)    | Added to velocity.y each frame.     |
| **groundY**  | Y value of the floor (px)        | When position.y ≥ groundY, we land and zero velocity.y. |
| **direction** | left / right                     | Sets scale.x to 1 or -1 to flip sprite. |
| **scale**    | Stretch/flip (x, y)              | We use scale.x = ±1 for facing.     |
| **dt**       | Seconds since last frame         | Used so movement is per-second.    |
| **anchor**   | Which pixel is “position”        | bottomCenter = feet at position.    |
