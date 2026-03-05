import 'package:flame/components.dart';
import 'package:flame_app/actor/player.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL – one game level (World), generic for any .tmx map
// Logic: loads the Tiled map by id (e.g. 'lvl-01', 'lvl-2'), then spawns
// player/enemies from an object layer. Same flow for every level.
// ═══════════════════════════════════════════════════════════════════════════

/// One game level: a Tiled map plus the player (and later enemies, items, etc.).
/// [World] = Flame's container for "everything in this level". The camera looks at this.
///
/// Pass [levelId] to load different maps (e.g. 'lvl-01' → lvl-01.tmx, 'lvl-2' → lvl-2.tmx).
class Level extends World {
  Level({
    this.levelId = 'lvl-01',
    this.tileSize = 16,
    this.spawnLayerName = 'SponPlayer',
  });

  /// Level id without .tmx (e.g. 'lvl-01', 'lvl-2'). Map file = assets/tiles/[levelId].tmx
  final String levelId;
  /// Tile size in pixels (same for all tiles in the map).
  final double tileSize;
  /// Tiled object layer name used for spawn points (Player, Enemy, etc.).
  final String spawnLayerName;

  late final TiledComponent _tileMap;

  String get _mapFileName => '$levelId.tmx';

  /// Runs once when the level is added to the game.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- 1) Load and add the map (drawn first = in the back) ---
    _tileMap = await TiledComponent.load(
      _mapFileName,
      Vector2.all(tileSize),
    );
    add(_tileMap);

    // --- 2) Spawn entities from Tiled object layer ---
    final spawnLayer = _tileMap.tileMap.getLayer<ObjectGroup>(spawnLayerName);
    for (final object in spawnLayer?.objects ?? []) {
      switch (object.class_) {
        case 'Player':
          add(Player(
            position: Vector2(object.x, object.y),
            character: PlayerCharacter.ninjaFrog,
          ));
          break;
        // Later: case 'Enemy': add(Enemy(...)); etc.
      }
    }
  }
}