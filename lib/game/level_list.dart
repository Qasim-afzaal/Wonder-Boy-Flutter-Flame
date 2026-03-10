/// Ordered list of level IDs (lvl-01 through lvl-20).
/// Used by [MyGame] to load next level when player reaches the goal.
const List<String> levelIds = [
  'lvl-01',
  'lvl-02',
  'lvl-03',
  'lvl-04',
  'lvl-05',
  'lvl-06',
  'lvl-07',
  'lvl-08',
  'lvl-09',
  'lvl-10',
  'lvl-11',
  'lvl-12',
  'lvl-13',
  'lvl-14',
  'lvl-15',
  'lvl-16',
  'lvl-17',
  'lvl-18',
  'lvl-19',
  'lvl-20',
];

int levelIndexFromId(String levelId) {
  final i = levelIds.indexOf(levelId);
  return i >= 0 ? i : 0;
}

String? nextLevelId(String levelId) {
  final i = levelIndexFromId(levelId) + 1;
  return i < levelIds.length ? levelIds[i] : null;
}
