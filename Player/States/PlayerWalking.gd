extends PlayerState

class_name PlayerWalking

func get_name() -> String:
	return PState.WALKING

func fixed_update(delta: float) -> String:
	_player.velocity.x = 0
	
	var dpad = _player.get_d_pad()
	
	_player.set_collision_dir(sign(dpad.x))
	_player.set_draw_dir(sign(dpad.x))
	
	_player.velocity.x = _player.walkSpeed * dpad.x
	_player.velocity += _player.gravity * delta
	
	_player.move()
	
	if _player.get_jump_pressed() and _player.is_on_floor():
		return PState.JUMPING
	if dpad.x == 0 and _player.is_on_floor():
		return PState.STANDING
	if _player.velocity.x == 0:
		return PState.STANDING
	if _player.is_on_floor() != true:
		return PState.FALLING
	
	return PState.WALKING