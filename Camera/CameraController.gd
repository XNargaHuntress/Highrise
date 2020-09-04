extends Camera

class_name CameraController

export(NodePath) var TargetPath
export(Vector2) var Offset := Vector2.ZERO
export(float) var LerpSpeed := 1.0
export(float) var Distance := 5.0
export(float) var ResetSpeed := 4.0

var distanceStack := []
var offsetStack := []

onready var _target: Spatial = self.get_node_or_null(TargetPath) as Spatial

func _process(delta: float) -> void:
	var targetPos := Offset + Vector2(_target.global_transform.origin.x, _target.global_transform.origin.y)
	var currentPos := Vector2(global_transform.origin.x, global_transform.origin.y)
	
	var targetZ = lerp(global_transform.origin.z, _target.global_transform.origin.z + Distance, ResetSpeed * delta)
	
	var moveTo = lerp(currentPos, targetPos, LerpSpeed * delta) as Vector2
	global_transform.origin = Vector3(moveTo.x, moveTo.y, targetZ)
	look_at(_target.global_transform.origin, Vector3.UP)
	return

func push_distance(dist: float) -> void:
	distanceStack.push_back(Distance)
	Distance = dist

func pop_distance() -> void:
	var dist = distanceStack.pop_back()
	Distance = dist

func push_offset(oset: Vector2) -> void:
	offsetStack.push_back(Offset)
	Offset = oset

func pop_offset() -> void:
	var oset = offsetStack.pop_back()
	Offset = oset