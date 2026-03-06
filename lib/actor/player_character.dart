/// Preset character folders under assets/images/. Pass to [Player] to choose sprite set.
enum PlayerCharacter {
  ninjaFrog('Main Characters/Ninja Frog'),
  pinkMan('Main Characters/Pink Man'),
  virtualGuy('Main Characters/Virtual Guy'),
  maskDude('Main Characters/Mask Dude');

  const PlayerCharacter(this.path);
  final String path;
}
