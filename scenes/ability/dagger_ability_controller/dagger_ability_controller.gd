extends Node

@export var max_range: float = 100
@export var dagger_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 3
var additional_damage_percent: float = 1
var base_wait_time: float
var dagger_amount: int = 1

func _ready() -> void:
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
		
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	
		
	enemies = enemies.filter(func(enemy: CharacterBody2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(max_range, 2)	
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	for i in dagger_amount:
		var dagger_instance = dagger_ability.instantiate() as DaggerAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		dagger_instance.target_enemy = enemies[0]
		foreground_layer.add_child(dagger_instance)
		
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "dagger_rate":
		var percent_reduction = current_upgrades["dagger_rate"]["quantity"] * 0.1
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "dagger_damage":
		additional_damage_percent = 1 + (current_upgrades["dagger_damage"]["quantity"] * 0.2 )
	elif upgrade.id == "dagger_amount":
		dagger_amount = 1 + current_upgrades["dagger_amount"]["quantity"]
