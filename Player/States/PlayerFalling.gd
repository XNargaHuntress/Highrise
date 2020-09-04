extends PlayerState

class_name PlayerFalling

var initialVelocity := Vector3()

var justEntered := false

func get_name() -> String:
	return PState.FALLING;

func enter(player) -> void:
	.enter(player)
	initialVelocity = player.velocity
	justEntered = true

func fixed_update(delta: float) -> String:
	var dpad = _player.get_d_pad()
	_player.set_collision_dir(sign(dpad.x))
	
	if initialVelocity.x == 0 || (dpad.x != 0 and sign(dpad.x) != sign(initialVelocity.x)):
		_player.velocity.x = initialVelocity.x + dpad.x * _player.walkSpeed * 0.5
	
	_player.velocity += _player.gravity * delta
	_player.move()
	
	if _player.is_on_floor():
		return PState.STANDING
	if _player.get_jump_pressed() and _player.hasExtraJump:
		_player.hasExtraJump = false
		return PState.JUMPING
	if _player.can_ledge_hang(dpad.x):
		return PState.LEDGE_HANGING
	if _player.can_wall_hang(dpad.x):
		return PState.WALL_HANGING
	
	justEntered = false
	return PState.FALLING;