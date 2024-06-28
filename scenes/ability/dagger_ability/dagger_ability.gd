extends Node2D
class_name DaggerAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent

@export var target_enemy: Node2D
@export var radius: float = 70.0

var starting_position: Vector2

func _ready() -> void:
	scale = Vector2.ZERO
	global_position = target_enemy.global_position
	global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 50.0
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
	tween.tween_method(tween_strike.bind(global_position), 0.0 , 1.0, 0.4)
	tween.tween_callback(queue_free).set_delay(0.6)

func tween_strike(percent: float, start_position: Vector2) -> void:
	if not target_enemy:
		return
	global_position = start_position.lerp(target_enemy.global_position, percent)
	var direction_from_start: Vector2 = target_enemy.global_position - start_position
	var target_rotation: float = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-10 * get_process_delta_time()))
