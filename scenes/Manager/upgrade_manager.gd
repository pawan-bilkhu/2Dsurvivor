extends Node


@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()


var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")

var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")

var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_damage = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_rate = preload("res://resources/upgrades/hammer_rate.tres")

var upgrade_dagger = preload("res://resources/upgrades/dagger.tres")
var upgrade_dagger_damage = preload("res://resources/upgrades/dagger_damage.tres")
var upgrade_dagger_rate = preload("res://resources/upgrades/dagger_rate.tres")
var upgrade_dagger_amount = preload("res://resources/upgrades/dagger_amount.tres")

var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")

func _ready() -> void:
	upgrade_pool.add_item(upgrade_axe, 3)
	upgrade_pool.add_item(upgrade_hammer, 3)
	upgrade_pool.add_item(upgrade_dagger, 10000)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 15)
	upgrade_pool.add_item(upgrade_player_speed, 7)
	
	experience_manager.level_up.connect(on_level_up)


func apply_upgrade(upgrade: AbilityUpgrade) -> void:
	var has_upgrade: bool = current_upgrades.has(upgrade.id)
	if not has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1,
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade) -> void:
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 12)
		upgrade_pool.add_item(upgrade_axe_rate, 10)
	if chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_damage, 12)
		upgrade_pool.add_item(upgrade_hammer_rate, 10)
	if chosen_upgrade.id == upgrade_dagger.id:
		upgrade_pool.add_item(upgrade_dagger_damage, 12)
		upgrade_pool.add_item(upgrade_dagger_rate, 10)
		upgrade_pool.add_item(upgrade_dagger_amount, 1000)

func pick_upgrades() -> Array:
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in 2:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades) as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
	return chosen_upgrades


func on_upgrade_selected(upgrade: AbilityUpgrade) -> void:
	apply_upgrade(upgrade)


func on_level_up(current_level: int) -> void:
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
