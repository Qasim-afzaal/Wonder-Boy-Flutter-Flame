import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'package:flame_app/actor/player_state.dart';
import 'package:flame_app/actor/player_character.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CHARACTER – what the character looks like (sprites, animations)
//
// No movement or input logic. Only: which folder, which animation files,
// frame counts, and building the SpriteAnimation map. Player uses this to
// know what to draw; Player handles where and how it moves.
// ═══════════════════════════════════════════════════════════════════════════

/// Holds all data needed to load and build a character's animations.
/// Pass a [Character] to [Player]; Player uses it in onLoad() and never touches sprite paths.
class Character {
  Character({
    required this.basePath,
    required this.textureSize,
    this.stepTime = 0.5,
    required this.animationData,
  });

  /// Folder under assets/images/ (e.g. 'Main Characters/Ninja Frog').
  final String basePath;
  /// Size of one frame in pixels (e.g. 32 for 32×32).
  final double textureSize;
  /// Seconds per animation frame.
  final double stepTime;
  /// For each [PlayerState], which file and how many frames.
  final Map<PlayerState, (String file, int frames)> animationData;

  /// Load all sprite sheets for this character into [images]. Call before [buildAnimations].
  Future<void> loadImages(Images images) async {
    final files = animationData.values.map((e) => e.$1).toSet();
    for (final file in files) {
      await images.load('$basePath/$file');
    }
  }

  /// Build the map of state → SpriteAnimation. Call after [loadImages].
  Map<PlayerState, SpriteAnimation> buildAnimations(Images images) {
    return {
      for (final e in animationData.entries)
        e.key: _buildSequence(
          images,
          '$basePath/${e.value.$1}',
          e.value.$2,
        ),
    };
  }

  SpriteAnimation _buildSequence(Images images, String path, int amount) {
    return SpriteAnimation.fromFrameData(
      images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(textureSize),
      ),
    );
  }

  // ─── Presets (same as PlayerCharacter enum, but as Character instances) ──

  static const _ninjaFrogData = {
    PlayerState.idle: ('Idle (32x32).png', 11),
    PlayerState.running: ('Run (32x32).png', 12),
    PlayerState.jumping: ('Jump (32x32).png', 1),
    PlayerState.falling: ('Fall (32x32).png', 1),
    PlayerState.doubleJump: ('Double Jump (32x32).png', 6),
    PlayerState.hit: ('Hit (32x32).png', 7),
    PlayerState.wallJump: ('Wall Jump (32x32).png', 6),
    PlayerState.dead: ('Hit (32x32).png', 7),
  };

  static Character ninjaFrog() => Character(
        basePath: 'Main Characters/Ninja Frog',
        textureSize: 32,
        stepTime: 0.5,
        animationData: _ninjaFrogData,
      );

  static Character pinkMan() => Character(
        basePath: 'Main Characters/Pink Man',
        textureSize: 32,
        stepTime: 0.5,
        animationData: _ninjaFrogData,
      );

  static Character virtualGuy() => Character(
        basePath: 'Main Characters/Virtual Guy',
        textureSize: 32,
        stepTime: 0.5,
        animationData: _ninjaFrogData,
      );

  static Character maskDude() => Character(
        basePath: 'Main Characters/Mask Dude',
        textureSize: 32,
        stepTime: 0.5,
        animationData: _ninjaFrogData,
      );

  /// Get a [Character] from the [PlayerCharacter] enum (for use in Level / menus).
  static Character from(PlayerCharacter preset) {
    return switch (preset) {
      PlayerCharacter.ninjaFrog => ninjaFrog(),
      PlayerCharacter.pinkMan => pinkMan(),
      PlayerCharacter.virtualGuy => virtualGuy(),
      PlayerCharacter.maskDude => maskDude(),
    };
  }
}
