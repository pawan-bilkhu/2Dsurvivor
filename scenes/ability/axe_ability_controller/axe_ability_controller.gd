extends Node

@export var axe_ability_scene: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 0.0
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1
var base_wait_time: float

var stats: Dictionary = {}

func _ready() -> void:
	stats = GameStats.get_weapon_stats("axe")
	
	if not stats.is_empty():
		base_damage = stats["damage"]["magnitude"]
		critical_chance = min(stats["critical_chance"]["magnitude"], 1.0)
		critical_damage = stats["critical_damage"]["magnitude"]
		base_wait_time = max(stats["attack_interval"]["magnitude"], 0.05)
		timer.wait_time = base_wait_time
		
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if not foreground_layer:
		return
	
	var axe_ability_instance = axe_ability_scene.instantiate() as AxeAbility
	foreground_layer.add_child(axe_ability_instance)
	axe_ability_instance.hitbox_component.damage = base_damage * additional_damage_percent
	axe_ability_instance.hitbox_component.critical_chance = critical_chance
	axe_ability_instance.hitbox_component.critical_damage = critical_damage
	
	axe_ability_instance.global_position = player.global_position


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * 0.1)
	if upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * 0.05
		timer.wait_time =  max(base_wait_time * (1 - percent_reduction), 0.05)
