extends Node

@export var max_range: float = 150

@export var hammer_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 15
var additional_damage_percent: float = 1
var base_wait_time: float

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
	
	var hammer_instance = hammer_ability.instantiate() as HammerAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(hammer_instance)
	
	hammer_instance.hitbox_component.damage = base_damage * additional_damage_percent
	
	var nearest_enemy = enemies[0] as CharacterBody2D
	var enemy_direction = nearest_enemy.velocity
	
	hammer_instance.global_position = nearest_enemy.global_position
	hammer_instance.global_position += Vector2(enemy_direction.x, 0) + 30*Vector2.UP
	
	
	hammer_instance.set_facing_direction(sign(enemy_direction.x))



func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "hammer_rate":
		var percent_reduction = current_upgrades["hammer_rate"]["quantity"] * 0.05
		timer.wait_time = base_wait_time * (1 - percent_reduction)
		timer.start()
	elif upgrade.id == "hammer_damage":
		additional_damage_percent = 1 + (current_upgrades["hammer_damage"]["quantity"] * 0.1)
