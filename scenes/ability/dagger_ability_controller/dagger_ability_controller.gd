extends Node

@export var max_range: float = 100
@export var dagger_ability: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 3
var additional_damage_percent: float = 1
var base_wait_time: float
var dagger_quantity: int = 5

func _ready() -> void:
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
		
	var enemies: Array = GameEvents.nearest_target_group("enemy", player, max_range)
	
	if enemies.size() == 0:
		return
	
	var enemy_position = enemies[0].global_position + 10*(dagger_quantity / 2)*Vector2.LEFT
	var distance_to_player: Vector2 = (player.global_position - enemy_position).normalized()
	
	
	for i in dagger_quantity:
		var dagger_instance = dagger_ability.instantiate() as DaggerAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		
		dagger_instance.target_position = enemy_position + (i)*10*(dagger_quantity / 2)*Vector2.RIGHT
		foreground_layer.add_child(dagger_instance)
		dagger_instance.hitbox_component.damage = base_damage * additional_damage_percent
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
