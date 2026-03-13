import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_app/game/my_game.dart';
import 'package:flame_app/levels/goal.dart';
import 'package:flame_app/levels/hazard.dart';
import 'package:flame_app/levels/fruit.dart';
import 'package:flame_app/actor/player_state.dart';
import 'package:flame_app/actor/player_direction.dart';
import 'package:flame_app/actor/character.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLAYER – movement and input logic only
//
// What it does: position, velocity, gravity, input, ground, direction, which
// animation state to show. It does NOT know sprite paths or frame counts;
// that lives in [Character]. We take a [Character] and use it in onLoad() to
// get the animations, then we only update position/velocity/current.
//
// Concepts: position, velocity, gravity, groundY, direction, dt (see CONCEPTS.md).
// ═══════════════════════════════════════════════════════════════════════════

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<MyGame>, CollisionCallbacks {
  Player({
    Vector2? position,
    Character? character,
    this.gravity = 800,
    this.moveSpeed = 200,
    this.jumpSpeed = -380,
    this.maxAirJumps = 1,
  })  : _character = character ?? Character.ninjaFrog(),
        super(
          position: position ?? Vector2.zero(),
          size: Vector2(32, 32),
          anchor: Anchor.bottomCenter,
        );

  /// Which character to draw (sprites, animations). Logic is in this class; look is in Character.
  final Character _character;

  // ─── Movement settings ──────────────────────────────────────────────────
  final double gravity;
  final double moveSpeed;
  final double jumpSpeed;
  final int maxAirJumps;

  // ─── State (changes every frame) ────────────────────────────────────────
  Vector2 velocity = Vector2.zero();
  PlayerDirection direction = PlayerDirection.right;
  double? groundY;
  int _airJumpsUsed = 0;
  bool _onGroundLastFrame = false;
  double _hitInvincibleUntil = 0;
  Vector2? _spawnPosition;

  bool get isOnGround => groundY != null && position.y >= groundY! - 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _character.loadImages(game.images);
    animations = _character.buildAnimations(game.images);

    current = PlayerState.idle;
    anchor = Anchor.bottomCenter;
    _spawnPosition = position.clone();
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Goal) {
      game.loadNextLevel();
      return;
    }
    if (other is Hazard) {
      game.gameState.lives--;
      hit();
      if (game.gameState.isGameOver) {
        game.gameOver();
      }
      return;
    }
    if (other is Fruit) {
      other.collect(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (current == PlayerState.dead) return;

    _applyInput();
    _applyGravity(dt);
    _applyMovement(dt);
    _applyGround();
    if (_hitInvincibleUntil > 0) _hitInvincibleUntil -= dt;
    // Fall off map -> die, lose life, respawn or game over
    if (groundY != null && position.y > groundY! + 200) {
      game.gameState.lives--;
      die();
      if (game.gameState.isGameOver) {
        game.gameOver();
      }
    }
    _updateDirection();
    _updateAnimationState();
    _onGroundLastFrame = isOnGround;
  }

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

    final canJump = isOnGround || (_airJumpsUsed < maxAirJumps && !_onGroundLastFrame);
    if (jump && canJump) {
      if (isOnGround) {
        _airJumpsUsed = 0;
        velocity.y = jumpSpeed;
      } else {
        _airJumpsUsed++;
        velocity.y = jumpSpeed;
        current = PlayerState.doubleJump;
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += gravity * dt;
  }

  void _applyMovement(double dt) {
    position += velocity * dt;
  }

  void _applyGround() {
    if (groundY != null && position.y >= groundY!) {
      position.y = groundY!;
      velocity.y = 0;
      if (_onGroundLastFrame) _airJumpsUsed = 0;
    }
  }

  void _updateDirection() {
    scale.x = direction == PlayerDirection.right ? 1 : -1;
  }

  void _updateAnimationState() {
    if (current == PlayerState.hit || current == PlayerState.dead) return;
    if (velocity.y < 0 && current != PlayerState.doubleJump) {
      current = PlayerState.jumping;
    } else if (velocity.y > 0) {
      current = PlayerState.falling;
    } else if (velocity.x != 0) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
  }

  /// Call when player is hurt (e.g. by hazard). Triggers hit state and optional respawn.
  void hit() {
    if (_hitInvincibleUntil > 0) return;
    _hitInvincibleUntil = 1.5;
    current = PlayerState.hit;
    velocity.setZero();
    // Respawn after a short delay (handled in update: reset position and state)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!isMounted) return;
      position.setFrom(_spawnPosition ?? position);
      velocity.setZero();
      current = PlayerState.idle;
    });
  }

  /// Call when player dies (e.g. fall in pit). Respawn at spawn point.
  void die() {
    current = PlayerState.dead;
    velocity.setZero();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!isMounted) return;
      position.setFrom(_spawnPosition ?? position);
      velocity.setZero();
      current = PlayerState.idle;
    });
  }
}
