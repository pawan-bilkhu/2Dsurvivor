extends Node

signal enemy_destroyed

const SPAWN_RADIUS: float = 350

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var crab_enemy_scene: PackedScene
@export var slime_enemy_scene: PackedScene
@export var cyclops_enemy_scene: PackedScene

@export var end_screen_scene: PackedScene

@onready var margin_container: MarginContainer = %MarginContainer
@onready var current_wave_label: Label = %CurrentWaveLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var enemy_count_label: Label = %EnemyCountLabel

var enemies: Array[PackedScene] = []
var current_wave: int = 0
var current_wave_capacity: int = 5
var wave_growth_rate: int = 5
var max_waves: int = 15

var enemy_count: int = 0
var additional_enemy_health: float = 0.0
var enemy_table: WeightedTable = WeightedTable.new()
var wave_in_progress: bool = false


func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 15)
	enemy_table.add_item(crab_enemy_scene, 15)
	
	margin_container.visible = false
	update_enemy_count_label(0)
	wave_start()


func wave_start() -> void:
	if wave_in_progress:
		return
	wave_in_progress = true
	if current_wave >= max_waves:
		var end_screen_instance = end_screen_scene.instantiate()
		add_child(end_screen_instance)
		end_screen_instance.play_jingle()
		MetaProgression.save()
		return
	
	await get_tree().create_timer(1.0).timeout
	
	current_wave += 1
	current_wave_label.text = "Wave: %d" % current_wave
	
	animation_player.play("RESET")
	margin_container.visible = true
	
	animation_player.play("in")
	await animation_player.animation_finished
	
	await get_tree().create_timer(1.0).timeout
	
	animation_player.play("out")
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	
	margin_container.visible = false
	generate_wave()


func generate_wave() -> void:
	if current_wave == 3:
		enemy_table.add_item(bat_enemy_scene, 15)
		
	
	if current_wave == 5:
		enemy_table.add_item(wizard_enemy_scene, 12)
	
	if current_wave == 7:
		enemy_table.add_item(slime_enemy_scene, 16)
		
	#if current_wave == 1:
		#while enemies.size() < 4:
			#enemies.append(bat_enemy_scene)
	#else:
		#while enemies.size() < current_wave_capacity:
			#enemies.append(enemy_table.pick_item())
	
	while enemies.size() < current_wave_capacity:
			enemies.append(enemy_table.pick_item())
	
	var entities_layer: Node2D = get_tree().get_first_node_in_group("entities_layer") as Node2D
	
	if not entities_layer:
		return
	
	for i in enemies.size():
		var enemy_instance = enemies.pop_front().instantiate()
		entities_layer.add_child(enemy_instance)
		enemy_instance.global_position = get_spawn_position()
		enemy_instance.health_component.set_max_health(enemy_instance.health_component.max_health + additional_enemy_health)
		enemy_instance.health_component.died.connect(on_enemy_died)
		enemy_count = GameEvents.get_enemy_count()
		update_enemy_count_label(enemy_count)
		await get_tree().create_timer(0.4).timeout
	
	current_wave_capacity += wave_growth_rate
	enemies = []


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


func update_enemy_count_label(count: int) -> void:
	enemy_count_label.text = "Enemies: %03d" % count


func on_enemy_died() -> void:
	enemy_count -= 1
	enemy_destroyed.emit()
	update_enemy_count_label(enemy_count)
	wave_complete_check()


func wave_complete_check() -> void:
	if enemy_count == 0:
		wave_in_progress = false
		wave_start()

