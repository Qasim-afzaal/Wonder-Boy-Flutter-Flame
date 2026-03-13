import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_app/game/my_game.dart';
import 'package:flutter/material.dart';

/// HUD overlay: lives and score. Add to camera or as overlay.
class HudComponent extends PositionComponent with HasGameReference<MyGame> {
  HudComponent({super.position});

  static const double _padding = 12;
  static const double _fontSize = 20;

  late TextPaint _textPaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textPaint = TextPaint(
      style: TextStyle(
        color: BasicPalette.white.color,
        fontSize: _fontSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1),
        ],
      ),
    );
    position.setValues(_padding, _padding);
    priority = 100;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final state = game.gameState;
    final livesText = 'Lives: ${state.lives}';
    final scoreText = 'Score: ${state.score}';
    _textPaint.render(canvas, livesText, Vector2(0, 0));
    _textPaint.render(canvas, scoreText, Vector2(0, _fontSize + 4));
  }
}
