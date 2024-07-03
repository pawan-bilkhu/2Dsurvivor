extends Node2D
class_name DaggerAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent

@export var target_position: Vector2

@export var radius: float = 70.0

var starting_position: Vector2


func _ready() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var player_direction: Vector2 = (player.global_position - target_position).normalized()
	starting_position = target_position + 30*Vector2.UP
	rotation = (target_position - global_position).angle() + PI
	
	scale = Vector2.ZERO
	global_position = starting_position
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

	
	tween.tween_method(tween_method.bind(global_position), 0.0 , 1.0, 0.4)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.2)
	
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(1.0)
	tween.chain()
	tween.tween_callback(queue_free)



func tween_method(percent: float, start_position: Vector2) -> void:
	global_position = start_position.lerp(Vector2(global_position.x, target_position.y), percent)
	
	

