extends KinematicBody

class_name PlayerController

# Export variables here
export(Vector3) var gravity := Vector3(0, -20, 0)
export(int) var walkSpeed := 8
export(int) var crawlSpeed := 1
export(int) var dashSpeed := 8
export(int) var jumpSpeed := 12
export(float) var hangTime := 2.0
export(float) var jumpTimeBuffer := 0.5

# Constants here
var stateDict = {
	PState.UNKNOWN: null,
	PState.CRAWLING: null,
	PState.FALLING: PlayerFalling.new(),
	PState.JUMPING: PlayerJumping.new(),
	PState.LEDGE_HANGING: PlayerLedgeHang.new(),
	PState.STANDING: PlayerStanding.new(),
	PState.SWINGING: null,
	PState.WALKING: PlayerWalking.new(),
	PState.WALL_HANGING: PlayerWallHang.new()
}

var frameDict = {
	PState.UNKNOWN: 0,
	PState.CRAWLING: 0,
	PState.FALLING: 1,
	PState.JUMPING: 1,
	PState.LEDGE_HANGING: 2,
	PState.STANDING: 0,
	PState.SWINGING: 1,
	PState.WALKING: 1,
	PState.WALL_HANGING: 2
}

# Public variables here
var wallCheckHigh := false
var wallCheckLow := false
var ledgeCheck := false

# Internal variables here
var state: PlayerState = null
var stateName := PState.UNKNOWN

var velocity := Vector3.ZERO

var collisionCheckDirection := 0

var hasExtraJump := false
var onJumpUseBuffer := false
var onJumpUseVelocity := false

var animationLock := false

# Public Functions
func set_animation(animationName: String) -> void:
	var frameId = frameDict[animationName]
	$PlayerSprite.frame = frameId
	return

func get_d_pad() -> Vector2:
	var h_value = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var v_value = Input.get_action_strength("player_up") - Input.get_action_strength("player_down")
	return Vector2(h_value, v_value)

func get_jump_pressed() -> bool:
	return Input.is_action_just_pressed("player_jump")

func get_jump_released() -> bool:
	return Input.is_action_just_released("player_jump")

func move(snap := true, stopOnSlope := true) -> void:
	var snapVector := Vector3.ZERO
	if snap:
		snapVector = gravity.normalized()
	
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector3.UP, stopOnSlope)
	return

func set_collision_dir(dir: int) -> void:
	if dir != collisionCheckDirection:
		collisionCheckDirection = dir
		if dir != 0:
			$LedgeCheck.cast_to.x = abs($LedgeCheck.cast_to.x) * sign(dir)
			$HandPosition.cast_to.x = abs($LedgeCheck.cast_to.x) * sign(dir)
			$WallCheckHigh.cast_to.x = abs($WallCheckHigh.cast_to.x) * sign(dir)
			$WallCheckLow.cast_to.x = abs($WallCheckLow.cast_to.x) * sign(dir)
			$LedgeCheck.force_raycast_update()
			$HandPosition.force_raycast_update()
			$WallCheckHigh.force_raycast_update()
			$WallCheckLow.force_raycast_update()
			pass
	return

func set_draw_dir(dir: int) -> void:
	if dir > 0:
		$PlayerSprite.flip_h = false
	if dir < 0:
		$PlayerSprite.flip_h = true
	return

func set_animation_lock(animationName: String) -> void:
	# TODO lock and play an animation
	if animationName == 'climb_ledge':
		transform.origin.y += 3.3
		transform.origin.x += collisionCheckDirection * 1.5
		set_draw_dir(collisionCheckDirection)
	return

func sweep_to_ledge() -> void:
	var direction := -0.1
	var collisionCheck := true
	if $HandPosition.is_colliding():
		direction = 0.1
		collisionCheck = false
	
	for i in range(10):
		move_and_collide(Vector3(0, direction, 0))
		$HandPosition.force_raycast_update()
		if $HandPosition.is_colliding() == collisionCheck:
			move_and_collide(Vector3(0, -direction, 0))
			break
	return

func can_wall_hang(hInput: float) -> bool:
	return hInput != 0 and wallCheckHigh and wallCheckLow and sign(collisionCheckDirection) == sign(hInput)

func is_holding_wall() -> bool:
	return !is_on_floor() and wallCheckHigh and wallCheckLow

func can_ledge_hang(hInput: float) -> bool:
	return hInput != 0 and wallCheckHigh and ledgeCheck == false and sign(collisionCheckDirection) == sign(hInput)

# Private Functions
func _ready() -> void:
	_set_state(PState.STANDING)
	return

func _input(event: InputEvent) -> void:
	if state:
		var newState := state.input(event)
		if newState != stateName:
			_set_state(newState)

func _physics_process(delta: float) -> void:
	wallCheckHigh = $WallCheckHigh.is_colliding()
	wallCheckLow = $WallCheckLow.is_colliding()
	ledgeCheck = $LedgeCheck.is_colliding()
	
	# DEBUG
	$LedgeInd.frame = 0 if $LedgeCheck.is_colliding() else 1
	$HandInd.frame = 8 if $HandPosition.is_colliding() else 9
	$WallHighInd.frame = 16 if $WallCheckHigh.is_colliding() else 17
	$WallLowInd.frame = 24 if $WallCheckLow.is_colliding() else 25
	$JumpInd.frame = 12 if hasExtraJump else 15

	if !state:
		return
	
	var oldStates := []
	var newState := state.fixed_update(delta)
	while newState != stateName:
		if oldStates.find(newState) == -1:
			oldStates.append(newState)
			
			_set_state(newState)
			
			if state:
				newState = state.fixed_update(delta)
	return

func _set_state(name: String) -> void:
	var oldState = stateName
	stateName = name
	state = stateDict[stateName]
	
	if state:
		set_animation(name)
		state.previousState = oldState
		state.enter(self)
	return