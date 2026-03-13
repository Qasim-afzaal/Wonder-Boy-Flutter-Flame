import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_app/actor/player.dart';
import 'package:flame_app/game/my_game.dart';

/// Collectible fruit: adds score and is removed when the player touches it.
/// Place in Tiled as object with class "Fruit" (optional custom property "points", default 10).
class Fruit extends SpriteComponent with HasGameReference<MyGame> {
  Fruit({
    required Vector2 position,
    required Sprite sprite,
    this.points = 10,
    Vector2? size,
  })  : _sprite = sprite,
        super(
          position: position,
          size: size ?? Vector2(32, 32),
          anchor: Anchor.center,
        );

  final Sprite _sprite;
  final int points;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = _sprite;
    add(RectangleHitbox());
  }

  void collect(Player player) {
    game.gameState.score += points;
    removeFromParent();
  }
}
