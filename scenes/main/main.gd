extends Node

@export var end_screen_scene: PackedScene
@export var floating_text_scene: PackedScene
@onready var wave_manager: Node = $WaveManager
@onready var player_stats_bar: CanvasLayer = $PlayerStatsBar


var pause_menu_scene: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
var eliminations: int
var experience_collected: int
var damage: float

func _ready() -> void:
	%Player.health_component.died.connect(on_player_died)
	wave_manager.enemy_destroyed.connect(on_enemy_destroyed)
	GameEvents.damage_dealt.connect(on_damage_dealt)
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	
	experience_collected= 0
	damage = 0.0
	player_stats_bar.set_damage_value(damage)
	eliminations = 0
	player_stats_bar.set_eliminations_value(eliminations)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
		get_tree().root.set_input_as_handled()


func on_player_died() -> void:
	var end_screen_scene_instance = end_screen_scene.instantiate()
	add_child(end_screen_scene_instance)
	end_screen_scene_instance.set_defeat()
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
