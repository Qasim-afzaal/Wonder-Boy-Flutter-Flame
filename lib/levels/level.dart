import 'package:flame/components.dart';
import 'package:flame_app/actor/player.dart';
import 'package:flame_app/actor/player_character.dart';
import 'package:flame_app/actor/character.dart';
import 'package:flame_app/levels/goal.dart';
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
    String levelId = 'lvl-01',
    this.tileSize = 16,
    this.spawnLayerName = 'SponPlayer',
  }) : _levelId = levelId;

  String _levelId;
  String get levelId => _levelId;
  final double tileSize;
  final String spawnLayerName;

  TiledComponent? _tileMap;

  String _mapFileName(String id) => '$id.tmx';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadContent(_levelId);
  }

  /// Load (or reload) level content by id. Used for first load and for next level.
  Future<void> _loadContent(String id) async {
    _levelId = id;
    removeAll(children);

    _tileMap = await TiledComponent.load(
      _mapFileName(id),
      Vector2.all(tileSize),
    );
    add(_tileMap!);

    final mapHeight = _tileMap!.tileMap.map.height;
    final mapWidth = _tileMap!.tileMap.map.width;
    final groundY = mapHeight * tileSize;

    ObjectGroup? spawnLayer = _tileMap!.tileMap.getLayer<ObjectGroup>(spawnLayerName);
    spawnLayer ??= _tileMap!.tileMap.getLayer<ObjectGroup>('sponPoint');
    for (final object in spawnLayer?.objects ?? []) {
      switch (object.class_) {
        case 'Player':
          final player = Player(
            position: Vector2(object.x, object.y),
            character: Character.from(PlayerCharacter.ninjaFrog),
          );
          player.groundY = groundY;
          add(player);
          break;
      }
    }

    Vector2? goalPosition;
    for (final name in ['Objects', spawnLayerName]) {
      final layer = _tileMap!.tileMap.getLayer<ObjectGroup>(name);
      for (final object in layer?.objects ?? []) {
        if (object.class_ == 'Goal') {
          goalPosition = Vector2(object.x, object.y + (object.height));
          break;
        }
      }
      if (goalPosition != null) break;
    }
    goalPosition ??= Vector2(mapWidth * tileSize - 50, groundY);
    add(Goal(position: goalPosition));
  }

  /// Reload this level with a new id (for next level). Keeps same world/camera.
  Future<void> loadLevel(String id) => _loadContent(id);
}
