import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_app/game/my_game.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// APP ENTRY – runs once when the app starts.
// GameWidget draws and runs MyGame every frame. MyGame lives in game/my_game.dart.
// ═══════════════════════════════════════════════════════════════════════════

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
