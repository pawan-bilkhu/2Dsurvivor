extends Node2D

@export var shadow_scene: PackedScene
@export var danger_warning_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line_2d: Line2D = $Line2D

var target_position: Vector2
var target_node: Node
var starting_position: Vector2
var danger_warning_instance: Node2D


func _ready() -> void:
	global_position = starting_position
	animation_player.play("launch")
	await animation_player.animation_finished
	
	var background_layer: Node = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	
	
	remove_child(line_2d)
	background_layer.add_child(line_2d)
	danger_warning_instance = danger_warning_scene.instantiate()
	background_layer.add_child(danger_warning_instance)
	
	var animation_duration: float = 1.5
	
	var tween = create_tween()
	tween.tween_method(tween_target, 0.0, 1.0, animation_duration)
	danger_warning_instance.start(animation_duration)
	tween.tween_callback(land.bind(background_layer))
	
	

func tween_target(percent: float) -> void:
	global_position = target_position
	ray_cast_2d.target_position = target_position
	line_2d.points[0] = ray_cast_2d.global_position
	line_2d.points[1] = ray_cast_2d.target_position
	danger_warning_instance.global_position = global_position
	line_2d.self_modulate.a = lerpf(0, 0.75 , percent)
	line_2d.width = lerpf(0.0, 3.0, percent)
	
	if not target_node:
		return
	
	target_position = target_node.global_position


func land(layer: Node) -> void:
	animation_player.play("land")
	global_position = target_position
	var shadow_instance: Node2D = shadow_scene.instantiate()
	shadow_instance.target_position = target_position
	layer.add_child(shadow_instance)


func emit_camera_shake() -> void:
	GameEvents.emit_camera_shake(global_position)


func destroy() -> void:
	var tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, 0.1)
	await tween.finished
	line_2d.queue_free()
	queue_free()
