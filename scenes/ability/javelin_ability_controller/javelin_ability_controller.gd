extends Node

@export var max_range: float = 200.0
@export var javelin_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 2.0
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1.0
var base_wait_time: float
var javelin_quantity: int = 1

var stats: Dictionary = {}

func _ready() -> void:
	stats = GameStats.get_weapon_stats("javelin")
	
	if not stats.is_empty():
		base_damage = stats["damage"]["magnitude"]
		critical_chance = min(stats["critical_chance"]["magnitude"], 1.0)
		critical_damage = stats["critical_damage"]["magnitude"]
		base_wait_time = max(stats["attack_interval"]["magnitude"], 0.05)
		
	timer.wait_time = base_wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _on_timer_timeout() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	
	for i in javelin_quantity:
		var enemies: Array = GameEvents.nearest_target_group("enemy", player, max_range)
	
		if enemies.size() == 0:
			return
	
		var javelin_instance: Node2D = javelin_ability.instantiate()
		
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		if not foreground_layer:
			return

		javelin_instance.target_enemy = enemies[0]
		javelin_instance.target_position = enemies[0].global_position
		
		await get_tree().create_timer(0.4).timeout
		foreground_layer.add_child(javelin_instance)
		javelin_instance.hitbox_component.damage = base_damage * additional_damage_percent
		javelin_instance.hitbox_component.critical_chance = critical_chance
		javelin_instance.hitbox_component.critical_damage = critical_damage


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "javelin_rate":
		var percent_reduction = current_upgrades["javelin_rate"]["quantity"] * 0.2
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "javelin_damage":
		additional_damage_percent = 1 + (current_upgrades["javelin_damage"]["quantity"] * 0.3)
	elif upgrade.id == "javelin_quantity":
		javelin_quantity = 1 + current_upgrades["javelin_quantity"]["quantity"]
		
