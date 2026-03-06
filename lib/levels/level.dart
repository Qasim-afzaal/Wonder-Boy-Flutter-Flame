import 'package:flame/components.dart';
import 'package:flame_app/actor/player.dart';
import 'package:flame_app/actor/player_character.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL – one game level (World)
//
// Concepts:
//   World  – Flame's container for "everything in this level". The camera draws this.
//   We add: 1) the Tiled map (background), 2) the Player at spawn points from the map.
//   position – we set Player's position from Tiled object (object.x, object.y) in pixels.
//   groundY – we set it to the bottom of the map (height in tiles × tileSize) so the
//             player has a floor to land on (see CONCEPTS.md: groundY).
// ═══════════════════════════════════════════════════════════════════════════

class Level extends World {
  Level({
    this.levelId = 'lvl-01',
    this.tileSize = 16,
    this.spawnLayerName = 'SponPlayer',
  });

  final String levelId;
  final double tileSize;
  final String spawnLayerName;

  late final TiledComponent _tileMap;

  String get _mapFileName => '$levelId.tmx';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _tileMap = await TiledComponent.load(
      _mapFileName,
      Vector2.all(tileSize),
    );
    add(_tileMap);

    final spawnLayer = _tileMap.tileMap.getLayer<ObjectGroup>(spawnLayerName);
    for (final object in spawnLayer?.objects ?? []) {
      switch (object.class_) {
        case 'Player':
          final player = Player(
            position: Vector2(object.x, object.y),
            character: PlayerCharacter.ninjaFrog,
          );
          player.groundY = _tileMap.tileMap.map.height * tileSize;
          add(player);
          break;
      }
    }
  }
}
