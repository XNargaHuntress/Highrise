extends Area

class_name Sandbox_NpcArea

export(float) var ZoomDistance := 8.0
export(Vector2) var Offset := Vector2.ZERO

var other = null
var camController: CameraController = null

func _ready():
	camController = get_tree().root.get_camera() as CameraController
	pass

func _process(delta):
	if other != null:
		$Sprite3D.flip_h = other.global_transform.origin.x < self.global_transform.origin.x
	pass

func _on_Area_body_entered(body):
	$Sprite3D/AnimationPlayer.play("Show")
	other = body
	
	if camController != null:
		camController.push_distance(ZoomDistance)
		camController.push_offset(Offset)
	pass # Replace with function body.


func _on_Area_body_exited(body):
	$Sprite3D/AnimationPlayer.play("Hide")
	other = null
	
	if camController != null:
		camController.pop_distance()
		camController.pop_offset()
	pass # Replace with function body.
