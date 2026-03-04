import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
class Level extends World {
  late final TiledComponent _tileMap;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _tileMap = await TiledComponent.load('lvl-01.tmx', Vector2.all(16));
    add(_tileMap);
  }
}