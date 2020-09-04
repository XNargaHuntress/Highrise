extends PlayerState

class_name PlayerWallHang

var jumpDirection := 0
var hangTimer := 0.0
var justEntered := false

func get_name() -> String:
	return PState.WALL_HANGING

func enter(player) -> void:
	.enter(player)
	player.velocity.y = 0
	
	# Hug the wall
	player.velocity.x = player.collisionCheckDirection * 10
	player.move()
	
	player.velocity.x = 0
	player.hasExtraJump = true

	jumpDirection = -sign(player.collisionCheckDirection)
	hangTimer = player.hangTime

	justEntered = true
	player.set_draw_dir(jumpDirection)
	return

func fixed_update(delta: float) -> String:
	var dpad = _player.get_d_pad()

	if _player.wallCheckHigh and _player.wallCheckLow and sign(dpad.x) == sign(_player.collisionCheckDirection):
		if hangTimer > 0:
			hangTimer -= delta
			_player.velocity.y = 0
		else:
			_player.velocity += _player.gravity * 0.25 * delta
	else:
		return PState.FALLING
	
	_player.move()

	if _player.is_on_floor():
		return PState.STANDING
	if _player.get_jump_pressed() and justEntered == false:
		_player.onJumpUseBuffer = true
		_player.velocity.x = jumpDirection * _player.walkSpeed
		_player.set_collision_dir(jumpDirection)
		return PState.JUMPING
	
	justEntered = false
	return PState.WALL_HANGING
