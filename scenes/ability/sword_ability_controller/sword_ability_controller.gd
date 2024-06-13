extends Node

@export var max_range: float = 150

@export var sword_ability: PackedScene
@onready var timer: Timer = $Timer

var damage = 5
var base_wait_time

func _ready() -> void:
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
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
	
	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = damage
	sword_instance.global_position = enemies[0].global_position
	sword_instance.global_position += Vector2.RIGHT.rotated((randf_range(0, TAU))) * 4
	
	var enemy_direction: Vector2 = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id != "sword_rate":
		return
	
	var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
	timer.wait_time = base_wait_time * (1 - percent_reduction)
	timer.start()
