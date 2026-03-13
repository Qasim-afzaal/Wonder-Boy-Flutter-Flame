import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_app/levels/level.dart';
import 'package:flame_app/game/level_list.dart';
import 'package:flame_app/game/game_state.dart';
import 'package:flame_app/overlays/hud.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MY GAME – root game (FlameGame)
//
// Concepts:
//   world   – the "scene" the camera looks at (our Level: map + player).
//   camera  – what part of the world we see on screen (viewport size, anchor).
//   We create one Level and one Camera once, then pass them to FlameGame so
//   they exist from frame 1 (avoids "camera not initialized" error).
// ═══════════════════════════════════════════════════════════════════════════

/// Level to load at start.
final String startLevelId = levelIds.first;

/// World is the Level so the camera sees it directly (original working setup).
/// Next level is done by reloading Level content, not replacing the world.
(Level, CameraComponent) createWorldAndCamera(String levelId) {
  final world = Level(levelId: levelId);
  final camera = CameraComponent.withFixedResolution(
    width: 640,
    height: 368,
    world: world,
  );
  return (world, camera);
}

/// Single level + camera instance. MyGame passes these into FlameGame.
final worldAndCamera = createWorldAndCamera(startLevelId);

class MyGame extends FlameGame<Level> {
  MyGame()
      : super(
          world: worldAndCamera.$1,
          camera: worldAndCamera.$2,
        );

  final GameState gameState = GameState();

  @override
  Color backgroundColor() => const Color(0xFF101012);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAllImages();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.add(HudComponent());
    gameState.resetForNewGame();
  }

  /// Loads a level by ID. Reloads the current world (Level) content.
  Future<void> loadLevel(String levelId) async {
    await world.loadLevel(levelId);
  }

  /// Called when lives reach 0. Resets lives and reloads current level.
  Future<void> gameOver() async {
    gameState.resetLivesOnly();
    await loadLevel(world.levelId);
  }

  /// Loads the next level in [levelIds], or does nothing if already at last level.
  Future<void> loadNextLevel() async {
    final nextId = nextLevelId(world.levelId);
    if (nextId != null) {
      await loadLevel(nextId);
    }
  }

  bool get isGameComplete => nextLevelId(world.levelId) == null;
}
