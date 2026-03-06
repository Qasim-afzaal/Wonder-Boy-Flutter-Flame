import 'package:flame/components.dart';
import 'package:flame_app/game/my_game.dart';
import 'package:flame_app/actor/player_state.dart';
import 'package:flame_app/actor/player_direction.dart';
import 'package:flame_app/actor/player_character.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLAYER
//
// Concepts used (see CONCEPTS.md for details):
//   position  – where the player is (x, y in pixels). We change it each frame with velocity.
//   velocity  – speed per second (x = horizontal, y = vertical). Input and gravity change it.
//   gravity   – downward acceleration; we add it to velocity.y each frame so the player falls.
//   groundY   – y-coordinate of the floor; when position.y >= groundY we "land" and set velocity.y = 0.
//   direction – left/right; we use it to set scale.x (1 or -1) so the sprite faces the right way.
//   scale.x   – 1 = face right, -1 = face left (flip sprite).
//   dt        – time since last frame in seconds; we use it so movement is "per second".
// ═══════════════════════════════════════════════════════════════════════════

class Player extends SpriteAnimationGroupComponent with HasGameRef<MyGame> {
  Player({
    Vector2? position,
    PlayerCharacter character = PlayerCharacter.ninjaFrog,
    this.textureSize = 32,
    this.stepTime = 0.5,
    this.gravity = 800,
    this.moveSpeed = 200,
    this.jumpSpeed = -380,
  })  : _basePath = character.path,
        super(position: position ?? Vector2.zero());

  // ─── Animation / sprite settings (set once) ─────────────────────────────
  final String _basePath;
  final double textureSize;
  final double stepTime;

  // ─── Movement settings (tunable numbers) ───────────────────────────────
  /// Downward acceleration in pixels per second². Added to velocity.y every frame.
  final double gravity;
  /// Horizontal speed in pixels per second when holding left/right.
  final double moveSpeed;
  /// Upward speed in pixels per second when jump is pressed (stored as negative = up).
  final double jumpSpeed;

  // ─── State that changes every frame ─────────────────────────────────────
  /// Current speed: .x = horizontal (px/s), .y = vertical (px/s). We add velocity * dt to position each frame.
  Vector2 velocity = Vector2.zero();
  /// Which way the sprite faces; we set scale.x from this (1 = right, -1 = left).
  PlayerDirection direction = PlayerDirection.right;
  /// Y-coordinate of the floor in pixels. When position.y >= groundY we clamp and set velocity.y = 0.
  double? groundY;

  /// True when velocity.y >= 0 (not moving up). We only allow jump when this is true.
  bool get isOnGround => velocity.y >= 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const animationData = {
      PlayerState.idle: ('Idle (32x32).png', 11),
      PlayerState.running: ('Run (32x32).png', 12),
      PlayerState.jumping: ('Jump (32x32).png', 1),
      PlayerState.falling: ('Fall (32x32).png', 1),
      PlayerState.doubleJump: ('Double Jump (32x32).png', 6),
      PlayerState.hit: ('Hit (32x32).png', 7),
      PlayerState.wallJump: ('Wall Jump (32x32).png', 6),
      PlayerState.dead: ('Hit (32x32).png', 7),
    };

    final files = animationData.values.map((e) => e.$1).toSet();
    for (final file in files) {
      await gameRef.images.load('$_basePath/$file');
    }

    animations = {
      for (final e in animationData.entries)
        e.key: buildSequenceAnimation(
          path: '$_basePath/${e.value.$1}',
          amount: e.value.$2,
          stepTime: stepTime,
          textureSize: textureSize,
        ),
    };

    current = PlayerState.idle;
    anchor = Anchor.bottomCenter;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (current == PlayerState.dead) return;

    _applyInput();
    _applyGravity(dt);
    _applyMovement(dt);
    _applyGround();
    _updateDirection();
    _updateAnimationState();
  }

  /// Set velocity.x and direction from keyboard (left/right, jump).
  void _applyInput() {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final moveLeft = keys.contains(LogicalKeyboardKey.arrowLeft) ||
        keys.contains(LogicalKeyboardKey.keyA);
    final moveRight = keys.contains(LogicalKeyboardKey.arrowRight) ||
        keys.contains(LogicalKeyboardKey.keyD);
    final jump = keys.contains(LogicalKeyboardKey.space) ||
        keys.contains(LogicalKeyboardKey.arrowUp) ||
        keys.contains(LogicalKeyboardKey.keyW);

    if (moveLeft) {
      velocity.x = -moveSpeed;
      direction = PlayerDirection.left;
    } else if (moveRight) {
      velocity.x = moveSpeed;
      direction = PlayerDirection.right;
    } else {
      velocity.x = 0;
    }

    if (jump && isOnGround) {
      velocity.y = jumpSpeed;
    }
  }

  /// Add gravity to velocity.y so the player accelerates downward.
  void _applyGravity(double dt) {
    velocity.y += gravity * dt;
  }

  /// Move position by velocity * dt (so movement is per second).
  void _applyMovement(double dt) {
    position += velocity * dt;
  }

  /// If we have a floor (groundY), clamp position and stop vertical velocity when we hit it.
  void _applyGround() {
    if (groundY != null && position.y >= groundY!) {
      position.y = groundY!;
      velocity.y = 0;
    }
  }

  /// Flip sprite left/right using scale.x from direction.
  void _updateDirection() {
    scale.x = direction == PlayerDirection.right ? 1 : -1;
  }

  /// Set current animation (idle / running / jumping / falling) from velocity.
  void _updateAnimationState() {
    if (velocity.y < 0) {
      current = PlayerState.jumping;
    } else if (velocity.y > 0) {
      current = PlayerState.falling;
    } else if (velocity.x != 0) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
  }

  SpriteAnimation buildSequenceAnimation({
    required String path,
    required int amount,
    double? stepTime,
    double? textureSize,
  }) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime ?? this.stepTime,
        textureSize: Vector2.all(textureSize ?? this.textureSize),
      ),
    );
  }
}
