extends PlayerState

class_name PlayerStanding

func get_name() -> String:
	return PState.STANDING

func enter(player) -> void:
	.enter(player)
	_player.velocity = Vector3.ZERO
	_player.hasExtraJump = true

func fixed_update(delta: float) -> String:
	_player.velocity += _player.gravity * delta

	_player.move()

	if _player.get_jump_pressed():
		return PState.JUMPING
	#if _player.get_d_pad().y < 0:
	#	return PState.CRAWLING
	if can_move():
		return PState.WALKING
	if _player.is_on_floor() != true:
		return PState.FALLING

	return PState.STANDING

func can_move() -> bool:
	var d_pad = _player.get_d_pad()
	_player.set_collision_dir(sign(d_pad.x))

	if d_pad.x != 0 && !_player.wallCheckHigh:
		return true
	else:
		return false