extends Reference

class_name PlayerState

var previousState := PState.UNKNOWN

var _player = null

func get_name() -> String:
	return PState.UNKNOWN

func enter(player) -> void:
	_player = player
	return

func exit() -> void:
	_player = null
	return

func input(event: InputEvent) -> String:
	return get_name()

func fixed_update(delta: float) -> String:
	return get_name()