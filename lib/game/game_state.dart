/// Global game state: lives and score.
/// Read/write from [MyGame] and HUD; hazards and collectibles update score/lives.
class GameState {
  GameState({this.lives = 3, this.score = 0});

  int lives;
  int score;

  void resetForNewGame() {
    lives = 3;
    score = 0;
  }

  void resetLivesOnly() {
    lives = 3;
  }

  bool get isGameOver => lives <= 0;
}
