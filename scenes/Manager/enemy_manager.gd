extends Node

const SPAWN_RADIUS: float = 350

@export var basic_enemy_scene: PackedScene


func _ready() -> void:
	pass 


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var spawn_postion = player.global_position + (random_direction*SPAWN_RADIUS)
	var enemy = basic_enemy_scene.instantiate() as CharacterBody2D
	get_parent().add_child(enemy)
	enemy.global_position = spawn_postion
