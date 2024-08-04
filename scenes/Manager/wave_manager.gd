extends Node

signal enemy_destroyed
signal wave_updated(wave: int)
signal remaining_enemies_updated(remaining_enemies: int, total_enemies: int)

const SPAWN_RADIUS: float = 350

@export var is_testing: bool = false
@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var crab_enemy_scene: PackedScene
@export var slime_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene


@onready var margin_container: MarginContainer = %MarginContainer
@onready var current_wave_label: Label = %CurrentWaveLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var wave_complete_stream_player: AudioStreamPlayer = $WaveCompleteStreamPlayer
@onready var wave_start_stream_player: AudioStreamPlayer = $WaveStartStreamPlayer


var health_percent_increase: float = 0.1

var enemies_in_wave: Array[PackedScene] = []
var enemies_in_scene: Array[Node2D] = []

var current_wave: int = 0
var current_wave_capacity: int = 0
var wave_growth_rate: int = 5
var max_waves: int = 20


var remaining_enemies: int = 0
var total_enemies: int = 0
var additional_enemy_health_percent: float = 0.0
var enemy_table: WeightedTable = WeightedTable.new()
var wave_in_progress: bool = false

var is_game_over: bool = false


func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 20)
	enemy_table.add_item(crab_enemy_scene, 20)
	
	margin_container.visible = false
	wave_start()


func wave_start() -> void:
	if is_game_over:
		return
	if wave_in_progress:
		return
	wave_in_progress = true
	
	
	await get_tree().create_timer(1.0).timeout
	current_wave += 1
	total_enemies = 0
	current_wave_label.text = "Wave: %d" % current_wave
	
	
	animation_player.play("RESET")
	margin_container.visible = true
	
	animation_player.play("in")
	wave_start_stream_player.play_random()
	
	await animation_player.animation_finished
	
	await get_tree().create_timer(1.0).timeout
	wave_updated.emit(current_wave)
	animation_player.play("out")
	wave_start_stream_player.play_random()
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	
	margin_container.visible = false
	generate_wave()


func generate_wave() -> void:
	if not is_testing:
		current_wave_capacity = wave_growth_rate * current_wave
		
		if current_wave == 2:
			enemy_table.add_item(wizard_enemy_scene, 17)
			
		if current_wave == 6:
			enemy_table.add_item(bat_enemy_scene, 13)
		
		if current_wave == 11:
			enemy_table.add_item(slime_enemy_scene, 15)
		
		if current_wave == 15:
			enemy_table.add_item(cyclops_enemy_scene, 10)
		
		if current_wave % 5 == 0:
			additional_enemy_health_percent += 0.10
			
			var boss_quantity: int = int(current_wave/5)
			
			while enemies_in_wave.size() < boss_quantity:
				enemies_in_wave.append(cyclops_enemy_scene)
				
			if current_wave % 10 == 0:
				while enemies_in_wave.size() < 3*boss_quantity:
					enemies_in_wave.append(slime_enemy_scene)
		else:
			while enemies_in_wave.size() < current_wave_capacity:
				enemies_in_wave.append(enemy_table.pick_item())
	else:
		while enemies_in_wave.size() < 25:
			enemies_in_wave.append(bat_enemy_scene)
	
	var entities_layer: Node2D = get_tree().get_first_node_in_group("entities_layer") as Node2D
	
	if not entities_layer:
		return
	
	total_enemies = enemies_in_wave.size()
	remaining_enemies = enemies_in_wave.size()
	remaining_enemies_updated.emit(remaining_enemies, total_enemies)
	
	enemies_in_scene = []
	
	while enemies_in_wave.size() > 0:
		var enemy_instance = enemies_in_wave.pop_front().instantiate()
		entities_layer.add_child(enemy_instance)
		enemies_in_scene.append(enemy_instance)
		enemy_instance.global_position = get_spawn_position()
		enemy_instance.health_component.set_max_health(enemy_instance.health_component.max_health + additional_enemy_health_percent*enemy_instance.health_component.max_health)
		enemy_instance.health_component.died.connect(on_enemy_died.bind(enemy_instance))
		await get_tree().create_timer(0.4).timeout
	


func get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return Vector2.ZERO
	
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in 16:
		spawn_position = player.global_position + (random_direction*SPAWN_RADIUS)
		var additional_check_offset: Vector2 = random_direction * 20
		# You must pass the bit shifted value of the Collision layer that corresponds with value 1, spo
		var query_parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result: Dictionary = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(PI/8)
	return spawn_position


func on_enemy_died(enemy_instance: Node2D) -> void:
	enemy_destroyed.emit()
	enemies_in_scene.erase(enemy_instance)
	
	remaining_enemies = enemies_in_scene.size()
	remaining_enemies_updated.emit(remaining_enemies, total_enemies)
	#print("Wave Manager")
	#print("Enemies remaining: %d, Total enemies: %d" % [remaining_enemies, total_enemies])
	wave_complete_check()


func wave_complete_check() -> void:
	if remaining_enemies == 0 && enemies_in_wave.size() == 0:
		wave_complete_stream_player.play_random()
		await get_tree().create_timer(0.5).timeout
		game_over_check()
		wave_in_progress = false
		wave_start()


func game_over_check() -> void:
	if current_wave >= max_waves:
		GameEvents.emit_game_over()
		is_game_over = true
