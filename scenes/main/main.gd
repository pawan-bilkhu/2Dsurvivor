extends Node

@export var end_screen_scene: PackedScene
@export var floating_text_scene: PackedScene


@onready var wave_manager: Node = $WaveManager
@onready var player_stats_bar: CanvasLayer = $PlayerStatsBar
@onready var arena_time_tracker_manager: Node = $ArenaTimeTrackerManager


var pause_menu_scene: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
var eliminations: int
var experience_collected: int
var damage: float
var time_elapsed: float

func _ready() -> void:
	%Player.health_component.died.connect(on_player_died)
	wave_manager.enemy_destroyed.connect(on_enemy_destroyed)
	GameEvents.damage_dealt.connect(on_damage_dealt)
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	GameEvents.game_over.connect(on_game_over)
	
	experience_collected= 0
	damage = 0.0
	time_elapsed = 0.0
	
	player_stats_bar.set_damage_value(get_damage())
	eliminations = 0
	player_stats_bar.set_eliminations_value(get_eliminations())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died() -> void:
	var end_screen_instance = end_screen_scene.instantiate()
	end_screen_instance.set_defeat()
	add_child(end_screen_instance)
	end_screen_instance.set_stats(get_time_elapsed(), get_damage(), get_eliminations())
	MetaProgression.save()


func on_enemy_destroyed() -> void:
	eliminations += 1
	player_stats_bar.set_eliminations_value(eliminations)


func on_damage_dealt(damage_amount: float) -> void:
	damage += damage_amount
	player_stats_bar.set_damage_value(damage)


func on_experience_vial_collected(experience: float) -> void:
	experience_collected += int(experience)
	player_stats_bar.set_experience_value(experience_collected)


func get_eliminations() -> int:
	return eliminations


func get_damage() -> float:
	return damage


func get_time_elapsed() -> float:
	time_elapsed = arena_time_tracker_manager.get_time_elapsed()
	return time_elapsed


func on_game_over() -> void:
	var experience_vials: Array = get_tree().get_nodes_in_group("experience_vial")
	for vial in experience_vials:
		vial.collect()
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_stats(get_time_elapsed(), get_damage(), get_eliminations())
	MetaProgression.save()
