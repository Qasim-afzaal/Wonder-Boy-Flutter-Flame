import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_app/levels/level.dart';
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

/// Level to load at start. Change to 'lvl-2', etc. to start on another map.
const String startLevelId = 'lvl-01';

/// Builds one Level (world) and one Camera that looks at it. Called once at startup.
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

class MyGame extends FlameGame {
  MyGame()
      : super(
          world: worldAndCamera.$1,
          camera: worldAndCamera.$2,
        );

  @override
  Color backgroundColor() => const Color(0xFF101012);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAllImages();
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}
