extends Node

@export var max_range: float = 100
@export var dagger_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 3
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1
var base_wait_time: float
var dagger_quantity: int = 1

var stats: Dictionary = {}

func _ready() -> void:
	stats = GameStats.get_weapon_stats("dagger")
	
	if not stats.is_empty():
		base_damage = stats["damage"]["magnitude"]
		critical_chance = min(stats["critical_chance"]["magnitude"], 1.0)
		critical_damage = stats["critical_damage"]["magnitude"]
		base_wait_time = max(stats["attack_interval"]["magnitude"], 0.05)
	
	timer.wait_time = base_wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	var enemies: Array = GameEvents.nearest_target_group("enemy", player, max_range)
	
	if enemies.size() == 0:
		return
	
	var enemy_position = enemies[0].global_position
	var enemy_velocity = enemies[0].velocity
	
	var length: float = 20.0 * float(dagger_quantity)
	var dagger_spacing: float = length / dagger_quantity
	
	for i in dagger_quantity:
		var dagger_instance = dagger_ability.instantiate() as DaggerAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		
		var direction: Vector2 = Vector2.ZERO
		
		if enemy_velocity.x >= 0:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		dagger_instance.target_position = enemy_position  + (i+1) * (dagger_spacing) * direction
		
		foreground_layer.add_child(dagger_instance)
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.hitbox_component.critical_chance = critical_chance
		dagger_instance.hitbox_component.critical_damage = critical_damage
		
		await get_tree().create_timer(0.1).timeout
	
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades["dagger_rate"]["quantity"] * 0.1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades["dagger_damage"]["quantity"] * 0.2 )
	elif upgrade.id == "dagger_quantity":
		dagger_quantity = 1 + current_upgrades["dagger_quantity"]["quantity"]
