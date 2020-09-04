extends PlayerState

class_name PlayerLedgeHang

var justEntered := false
var endState := false
var jumpDirection := 0

func get_name() -> String:
	return PState.LEDGE_HANGING

func enter(player) -> void:
	.enter(player)
	player.velocity.y = 0
	
	# Hug the wall
	player.velocity.x = player.collisionCheckDirection * 10
	player.move()
	
	player.velocity.x = 0
	player.hasExtraJump = true
	jumpDirection = -sign(player.collisionCheckDirection)
	justEntered = true
	player.set_draw_dir(jumpDirection)
	player.sweep_to_ledge()
	endState = false

func fixed_update(delta: float) -> String:
	var dpad = _player.get_d_pad()

	_player.move()

	if _player.is_on_floor():
		return PState.STANDING
	
	if endState == false:
		if dpad.y < 0 and sign(dpad.x) != sign(_player.collisionCheckDirection):
			return PState.FALLING
		elif dpad.y < 0 and sign(dpad.x):
			return PState.WALL_HANGING
		elif dpad.y > 0:
			endState = true
			_player.set_animation_lock('climb_ledge')
		elif _player.get_jump_pressed() and justEntered == false:
			_player.onJumpUseBuffer = true
			_player.velocity.x = jumpDirection * _player.walkSpeed
			_player.set_collision_dir(jumpDirection)
			return PState.JUMPING
	
	if endState == true and _player.animationLock == false:
		return PState.STANDING
	
	justEntered = false
	
	return PState.LEDGE_HANGING