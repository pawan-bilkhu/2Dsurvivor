extends Node

const RANGE = 200


@export var projectile_scene: PackedScene
@export var health_component: HealthComponent
@export var danger_warning_scene: PackedScene

@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = %RayCast2D
@onready var line_2d: Line2D = %Line2D


var danger_warning_instance: Node2D

func _ready() -> void:
	timer.start(randf_range(4.0, 7.0))
	
	var background_layer = get_tree().get_first_node_in_group("background_layer")
	remove_child(line_2d)
	background_layer.add_child(line_2d)
	health_component.died.connect(destroy_background_layer_components)


func destroy_background_layer_components() -> void:
	line_2d.queue_free()


func _on_timer_timeout() -> void:
	if randf() > 0.5:
		return
	
	var player_group: Array = GameEvents.nearest_target_group("player", owner, RANGE)
	
	if player_group.is_empty():
		return
	
	var player: Node2D = player_group[0]
	
	var background_layer = get_tree().get_first_node_in_group("background_layer")
	
	danger_warning_instance = danger_warning_scene.instantiate()
	background_layer.add_child(danger_warning_instance)
	
	var animation_duration: float = 0.5
	
	var tween = create_tween().set_parallel()
	tween.tween_method(tween_target.bind(player), 0.0, 1.0, animation_duration)
	danger_warning_instance.start(animation_duration)
	tween.tween_method(tween_stop, 0.0 , 1.0, 0.1).set_delay(0.4)
	tween.chain().tween_callback(create_spit_projectile.bind(player))
	timer.wait_time = randf_range(4.0, 7.0)


func create_spit_projectile(player: Node2D) -> void:
	var foreground_layer: Node = get_tree().get_first_node_in_group("foreground_layer")
	if not foreground_layer:
		return
	
	var projectile_instance = projectile_scene.instantiate()
	foreground_layer.add_child(projectile_instance)
	var direction_to_player: Vector2 = player.global_position - owner.global_position
	var distance: float = direction_to_player.length()
	projectile_instance.launch_projectile(owner.global_position, direction_to_player, distance, deg_to_rad(80))


func tween_target(percent: float, target_node: Node2D) -> void:
	ray_cast_2d.global_position = owner.global_position
	ray_cast_2d.target_position = target_node.global_position
	line_2d.points[0] = ray_cast_2d.global_position
	line_2d.points[1] = ray_cast_2d.target_position
	danger_warning_instance.global_position = ray_cast_2d.target_position
	line_2d.self_modulate.a = lerpf(0, 0.50 , percent)
	line_2d.width = lerpf(0.0, 5.0, percent)


func tween_stop(percent: float) -> void:
	line_2d.width = lerpf(line_2d.width, 0.0, percent)
