extends PlayerState

class_name PlayerJumping

var initialVelocity := Vector3.ZERO
var bufferTime := 0.0

var pressCount := 0
var releaseCount := 0

var justEntered := false

func get_name() -> String:
	return PState.JUMPING

func enter(player) -> void:
	.enter(player)

	pressCount = 1
	releaseCount = 0
	justEntered = true

	if player.onJumpUseVelocity == false:
		player.velocity.y = player.jumpSpeed
	
	initialVelocity = player.velocity

	if player.onJumpUseBuffer == true:
		bufferTime = player.jumpTimeBuffer
	else:
		bufferTime = 0
	
	player.onJumpUseBuffer = false
	player.onJumpUseVelocity = false
	return

func handle_input(delta: float, dpad: Vector2) -> void:
	if bufferTime > 0:
		bufferTime -= delta
	
	if bufferTime <= 0:
		_player.set_collision_dir(sign(dpad.x))
		if dpad.x != 0 and sign(dpad.x) != sign(initialVelocity.x):
			_player.velocity.x = initialVelocity.x + dpad.x * _player.walkSpeed * 0.5
	
	if justEntered == false and _player.get_jump_pressed() and _player.hasExtraJump:
		_player.hasExtraJump = false
		_player.velocity.y = _player.jumpSpeed
		pressCount += 1
	
	if justEntered == false and _player.get_jump_released() and _player.velocity.y > _player.jumpSpeed * 0.5 and releaseCount < pressCount:
		_player.velocity.y = _player.jumpSpeed * 0.5
		releaseCount += 1
	
	return

func fixed_update(delta: float) -> String:
	var dpad = _player.get_d_pad()
	handle_input(delta, dpad)

	_player.velocity += _player.gravity * delta
	_player.move(false, false)

	if bufferTime <= 0:
		if initialVelocity.x < _player.walkSpeed * 0.5:
			_player.set_draw_dir(sign(dpad.x))
	else:
		_player.set_draw_dir(sign(initialVelocity.x))
	
	if _player.is_on_floor():
		return PState.STANDING
	if justEntered == false and _player.can_ledge_hang(dpad.x):
		return PState.LEDGE_HANGING
	if justEntered == false and _player.can_wall_hang(dpad.x):
		return PState.WALL_HANGING
	if _player.velocity.y < 0:
		return PState.FALLING
	
	justEntered = false
	return PState.JUMPING