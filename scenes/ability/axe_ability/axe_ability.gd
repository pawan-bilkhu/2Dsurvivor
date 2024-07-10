extends Node2D
class_name AxeAbility

const MAX_RADIUS = 100

@onready var hitbox_component: HitboxComponent = $HitboxComponent

var base_rotation: Vector2

func _ready() -> void:
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3)
	tween.tween_callback(queue_free)


func tween_method(rotations: float) -> void:
	var percent: float = (rotations / 2)
	var current_radius: float = percent * MAX_RADIUS
	var current_direction: Vector2 = base_rotation.rotated(rotations * TAU)
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	global_position = player.global_position + (current_direction * current_radius)
