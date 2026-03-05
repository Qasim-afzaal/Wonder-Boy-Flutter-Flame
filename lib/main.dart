import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_app/levels/level.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY POINT – runs once when the app starts
// ═══════════════════════════════════════════════════════════════════════════

/// App entry point. Sets up Flutter/Flame and runs the game.
void main() {
  // Required before any Flutter/Flame APIs. Tells Flutter the engine is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // On phones/tablets: go fullscreen and lock to landscape.
  // On desktop this would show a warning, so we only do it on mobile.
  final isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (isMobile) {
    Flame.device.fullScreen();
    Flame.device.setLandscape();
  }

  runApp(GameWidget(game: MyGame()));
}

// ═══════════════════════════════════════════════════════════════════════════
// MY GAME – root game class (FlameGame)
// Needs a World (our Level) and a Camera that looks at it. We create both once
// and pass them to FlameGame. To start on another level, change the id below.
// ═══════════════════════════════════════════════════════════════════════════

/// Which level to load at start. Change to 'lvl-2', etc. to start on another map.
const String _startLevelId = 'lvl-01';

/// Builds one Level and one Camera that looks at it. Called once for the game.
(Level, CameraComponent) _createWorldAndCamera(String levelId) {
  final world = Level(levelId: levelId);
  final camera = CameraComponent.withFixedResolution(
    width: 640,
    height: 368,
    world: world,
  );
  return (world, camera);
}

// One level + one camera, created once. MyGame uses these.
final _worldAndCamera = _createWorldAndCamera(_startLevelId);

/// The root game class. Holds the camera, world (level), and runs the game loop.
class MyGame extends FlameGame {
  /// Pass the level and camera we created above into FlameGame.
  MyGame()
      : super(
          world: _worldAndCamera.$1,
          camera: _worldAndCamera.$2,
        );

  @override
  Color backgroundColor() => const Color(0xFF101012);

  // --- onLoad: runs once when the game is ready ---
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Preload all images so Player (and others) can use fromCache() without loading first.
    await images.loadAllImages();

    // (0,0) = top-left of the screen. Change anchor if you want (0,0) at center, etc.
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}

