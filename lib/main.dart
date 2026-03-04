import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_app/levels/level.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  if (isMobile) {
    Flame.device.fullScreen();
    Flame.device.setLandscape();
  }
  runApp(GameWidget(game: MyGame()));

}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF101012);
  // Create world and camera first, then pass to FlameGame so they're ready before first build.
  static final Level _world = Level();
  static final CameraComponent _camera = CameraComponent.withFixedResolution(
    width: 640,
    height: 368,
    world: _world,
  );

  MyGame() : super(world: _world, camera: _camera);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}

