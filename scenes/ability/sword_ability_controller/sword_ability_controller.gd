extends Node

@export var max_range: float = 150

@export var sword_ability: PackedScene
@onready var timer: Timer = $Timer

var base_damage: float = 5
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1
var base_wait_time: float

var stats: Dictionary = {}

func _ready() -> void:
	stats = GameStats.get_weapon_stats("sword")
	
	if not stats.is_empty():
		base_damage = stats["base_damage"]
		critical_chance = stats["critical_chance"]
		critical_damage = stats["critical_damage"]
		base_wait_time = max(stats["attack_interval"], 0.05)
		
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
		
	var enemies: Array = GameEvents.nearest_target_group("enemy", player, max_range)
	
	if enemies.size() == 0:
		return
	
	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = base_damage * additional_damage_percent
	sword_instance.hitbox_component.critical_chance = critical_chance
	sword_instance.hitbox_component.critical_damage = critical_damage
	
	sword_instance.global_position = enemies[0].global_position
	sword_instance.global_position += Vector2.RIGHT.rotated((randf_range(0, TAU))) * 4
	
	var enemy_direction: Vector2 = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
		timer.wait_time = max(base_wait_time * (1 - percent_reduction), 0.05)
		timer.start()
	elif upgrade.id == "sword_damage":
		additional_damage_percent = 1 + (current_upgrades["sword_damage"]["quantity"] * 0.15)

