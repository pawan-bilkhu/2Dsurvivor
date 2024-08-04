extends Node

@export var dagger_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 3
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1.0
var additional_critical_chance: float = 0.0
var base_wait_time: float
var dagger_quantity: int = 1

var stats: WeaponStats

func _ready() -> void:
	stats = GameStats.get_weapon_stats_resource("dagger")
	
	if stats != null:
		base_damage = stats.damage
		critical_chance = min(stats.critical_chance, 1.0)
		critical_damage = stats.critical_damage
		base_wait_time = max(stats.attack_interval, 0.05)
	
	timer.wait_time = base_wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	
	for i in dagger_quantity:
		var dagger_instance = dagger_ability.instantiate() as DaggerAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		
		var direction: Vector2 = Vector2.ZERO
		
		dagger_instance.direction = player.get_facing_direction()
		dagger_instance.global_position = player.marker_2d.global_position
		
		foreground_layer.add_child(dagger_instance)
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
		dagger_instance.hitbox_component.critical_chance = min(critical_chance + additional_critical_chance, 1.0)
		dagger_instance.hitbox_component.critical_damage = critical_damage
		
		await get_tree().create_timer(0.15).timeout
	
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades["dagger_rate"]["quantity"] * 0.1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades["dagger_damage"]["quantity"] * 0.2 )
	elif upgrade.id == "dagger_quantity":
		dagger_quantity = 1 + current_upgrades["dagger_quantity"]["quantity"]
