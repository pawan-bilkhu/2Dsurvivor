extends Node

const SPAWN_RADIUS: float = 350

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer: Timer = $Timer

var base_spawn_time: float = 0.0
var enemy_table: WeightedTable = WeightedTable.new()
var wave_capacity = 1

func _ready() -> void:
	base_spawn_time = timer.wait_time
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	enemy_table.add_item(basic_enemy_scene, 10)


func on_arena_difficulty_increased(arena_difficulty: int) -> void:
	var time_off = (0.1 / 12) * arena_difficulty
	time_off = min(time_off, 0.7)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:
		enemy_table.add_item(wizard_enemy_scene, 15)
	elif arena_difficulty == 18:
		enemy_table.add_item(bat_enemy_scene, 8)
	
	if (arena_difficulty % 6) == 0:
		wave_capacity += 1


func get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return Vector2.ZERO
	
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 4:
		spawn_position = player.global_position + (random_direction*SPAWN_RADIUS)
		var additional_check_offset: Vector2 = random_direction * 20
		# You must pass the bit shifted value of the Collision layer that corresponds with value 1, spo
		var query_parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result: Dictionary = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	return spawn_position


func _on_timer_timeout() -> void:
	timer.start()
	
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	if get_tree().get_nodes_in_group("enemy").size() > 50:
		return
		
	for i in wave_capacity:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as CharacterBody2D
		
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()

