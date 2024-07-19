extends Node

const RANGE = 200


@export var velocity_component: VelocityComponent
@export var health_component: HealthComponent
@export var entity: CharacterBody2D

@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = %RayCast2D
@onready var line_2d: Line2D = %Line2D


func _ready() -> void:
	
	timer.wait_time = randf_range(4.0, 7.0)
	timer.start()
	
	var background_layer = get_tree().get_first_node_in_group("background_layer")
	remove_child(line_2d)
	background_layer.add_child(line_2d)
	health_component.died.connect(destroy_line_2d)


func destroy_line_2d() -> void:
	line_2d.queue_free()


func _on_timer_timeout() -> void:
	var player_group: Array = GameEvents.nearest_target_group("player", owner, RANGE)
	
	if player_group.is_empty():
		return
	
	var player: Node2D = player_group[0]
	
	
	var tween = create_tween().set_parallel()
	tween.tween_method(tween_target.bind(player), 0.0, 1.0, 1.0)
	tween.tween_method(tween_stop, 0.0 , 1.0, 0.1).set_delay(0.9)
	tween.chain()
	tween.tween_callback(entity.set_can_dash.bind(true))
	return



func tween_target(percent: float, target_node: Node2D) -> void:
	ray_cast_2d.global_position = owner.global_position
	ray_cast_2d.target_position = target_node.global_position
	line_2d.points[0] = ray_cast_2d.global_position
	line_2d.points[1] = ray_cast_2d.target_position
	line_2d.self_modulate.a = lerpf(0, 0.75 , percent)
	line_2d.width = lerpf(0.0, 5.0, percent)


func tween_stop(percent: float) -> void:
	line_2d.width = lerpf(line_2d.width, 0.0, percent)
