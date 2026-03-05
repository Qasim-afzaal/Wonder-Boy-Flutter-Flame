import 'package:flame/components.dart';
import 'package:flame_app/main.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLAYER – character component
// Logic: knows which animation to show per state (idle, run, jump, etc.),
// loads sprites for the chosen character, builds animations. Position and
// character come from the constructor (Level sets them when spawning).
// Movement / input logic would go in update() or input handlers later.
// ═══════════════════════════════════════════════════════════════════════════

/// Which animation to show. Set [Player.current] to this (e.g. when moving → running).
enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  doubleJump,
  hit,
  wallJump,
  dead,
}

/// Preset character folders under assets/images/. Pass in constructor to pick sprite set.
enum PlayerCharacter {
  ninjaFrog('Main Characters/Ninja Frog'),
  pinkMan('Main Characters/Pink Man'),
  virtualGuy('Main Characters/Virtual Guy'),
  maskDude('Main Characters/Mask Dude');

  const PlayerCharacter(this.path);
  final String path;
}

/// Player = one of several sprite animations (idle, run, jump, ...). Switches by [current].
/// HasGameRef<MyGame> = access to game (e.g. gameRef.images to load/cache sprites).
class Player extends SpriteAnimationGroupComponent with HasGameRef<MyGame> {
  Player({
    Vector2? position,
    PlayerCharacter character = PlayerCharacter.ninjaFrog,
    this.textureSize = 32,
    this.stepTime = 0.5,
  })  : _basePath = character.path,
        super(position: position ?? Vector2.zero());

  final String _basePath;
  final double textureSize;
  final double stepTime;

  /// Runs once when the player is added to the level. Loads sprites and builds all animations.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- Data: which state uses which sprite file and how many frames ---
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

    // --- Load sprite sheets into cache (must happen before fromCache) ---
    final files = animationData.values.map((e) => e.$1).toSet();
    for (final file in files) {
      await gameRef.images.load('$_basePath/$file');
    }

    // --- Build one SpriteAnimation per state and assign to [animations] map ---
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
  }

  /// Generic helper: one sprite sheet (row of frames) → one SpriteAnimation.
  /// Used for every state; reusable for other characters or sprites.
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
