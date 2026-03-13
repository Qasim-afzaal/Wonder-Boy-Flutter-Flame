import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_app/game/my_game.dart';

/// Obstacle/hazard: hurts the player on contact (loses life, respawn).
/// Place in Tiled as object with class "Hazard" (rectangle).
class Hazard extends PositionComponent with HasGameReference<MyGame> {
  Hazard({required Vector2 position, Vector2? size})
      : super(
          position: position,
          size: size ?? Vector2(32, 32),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }
}
