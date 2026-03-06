/// Which animation the player is showing (idle, run, jump, fall, etc.).
/// Set [Player.current] to one of these so the right animation plays.
enum PlayerState {
  idle,
  running,
  jumping,
  falling,
  doubleJump,
  hit,
  wallJump,
  dead,
}
