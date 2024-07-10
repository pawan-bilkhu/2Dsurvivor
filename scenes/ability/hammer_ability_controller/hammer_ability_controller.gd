extends Node

@export var max_range: float = 150

@export var hammer_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 15
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1

var base_wait_time: float

var stats: Dictionary = {}

func _ready() -> void:
	stats = GameStats.get_weapon_stats("hammer")
	
	if not stats.is_empty():
		base_damage = stats["base_damage"]
		critical_chance = stats["critical_chance"]
		critical_damage = stats["critical_damage"]
		base_wait_time = max(stats["attack_interval"], 0.05)
		
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
		
	var enemies: Array = GameEvents.nearest_target_group("enemy", player, max_range)
	if enemies.size() == 0:
		return

	
	var hammer_instance = hammer_ability.instantiate() as HammerAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(hammer_instance)
	
	hammer_instance.hitbox_component.damage = base_damage * additional_damage_percent
	hammer_instance.hitbox_component.critical_chance = critical_chance
	hammer_instance.hitbox_component.critical_damage = critical_damage
	
	var nearest_enemy = enemies[0] as CharacterBody2D
	var enemy_direction = nearest_enemy.velocity
	
	hammer_instance.global_position = nearest_enemy.global_position
	hammer_instance.global_position += Vector2(enemy_direction.x, 0) + 30*Vector2.UP
	
	
	hammer_instance.set_facing_direction(sign(enemy_direction.x))



func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "hammer_rate":
		var percent_reduction = current_upgrades["hammer_rate"]["quantity"] * 0.05
		timer.wait_time = max(base_wait_time * (1 - percent_reduction), 0.05)
		timer.start()
	elif upgrade.id == "hammer_damage":
		additional_damage_percent = 1 + (current_upgrades["hammer_damage"]["quantity"] * 0.1)
