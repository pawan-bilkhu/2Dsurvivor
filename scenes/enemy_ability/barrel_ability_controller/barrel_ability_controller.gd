extends Node

const RANGE = 200

@export var barrel_scene: PackedScene

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = randf_range(5.0, 7.0)
	timer.start()


func _on_timer_timeout() -> void:
	if randf() > 0.5:
		return
	
	var player_group: Array = GameEvents.nearest_target_group("player", owner, RANGE)
	
	if player_group.is_empty():
		return
	
	var player: Node2D = player_group[0]
	
	var foreground_layer: Node = get_tree().get_first_node_in_group("foreground_layer")
	if not foreground_layer:
		return
		
	var barrel_instance: Node2D = barrel_scene.instantiate()
	barrel_instance.starting_position = owner.global_position + 20*Vector2.UP
	barrel_instance.target_position = player.global_position
	barrel_instance.target_node = player
	foreground_layer.add_child(barrel_instance)
	
	
