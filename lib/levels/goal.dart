import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_app/game/my_game.dart';

/// Invisible trigger that loads the next level when the player overlaps it.
/// Add to level at the end of the path (or read from Tiled object with class "Goal").
class Goal extends PositionComponent with HasGameReference<MyGame> {
  Goal({required Vector2 position, Vector2? size})
      : super(
          position: position,
          size: size ?? Vector2(32, 64),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await add(RectangleHitbox());
  }
}
