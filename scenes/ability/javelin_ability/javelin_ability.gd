extends Node2D

const MAX_RADIUS: float = 30.0

@export var target_position: Vector2
@export var target_enemy: Node2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent


var tween: Tween
var starting_position: Vector2

func _ready() -> void:
	scale = Vector2.ZERO
	
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	starting_position = player.global_position + 15 * Vector2.RIGHT.rotated(randf_range(0, TAU))
	global_position = starting_position
	
	rotation = (target_position - starting_position).angle()
	
	tween = create_tween()
	
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_method(tween_method, 0.0, 1.0 , 0.8)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.2)
	
	tween.chain()
	tween.tween_callback(queue_free)


func tween_method(percent: float) -> void:

	var enemy_direction: Vector2 = target_position - starting_position
	var midpoint: Vector2 = starting_position + (enemy_direction / 2) + enemy_direction.orthogonal()

	global_position = _quadratic_bezier(starting_position, midpoint, target_position, percent)
	var target_vector: Vector2 = global_position.bezier_derivative(starting_position, midpoint, target_position, percent)
	
	rotation = lerp_angle(rotation, target_vector.angle() + PI, 1 - exp(-5 * get_process_delta_time()))
	
	if not target_enemy:
		return
	
	target_position = target_enemy.global_position

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r


func destroy() -> void:
	tween.stop()
	queue_free()


