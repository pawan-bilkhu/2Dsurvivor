extends Node


@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

# axe ability and upgrades
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")

# sword upgrades
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")

# hammer ability and upgrades
var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_damage = preload("res://resources/upgrades/hammer_damage.tres")
var upgrade_hammer_rate = preload("res://resources/upgrades/hammer_rate.tres")

# dagger ability and upgrades
var upgrade_dagger = preload("res://resources/upgrades/dagger.tres")
var upgrade_dagger_damage = preload("res://resources/upgrades/dagger_damage.tres")
var upgrade_dagger_rate = preload("res://resources/upgrades/dagger_rate.tres")
var upgrade_dagger_quantity = preload("res://resources/upgrades/dagger_quantity.tres")

# javelin ability and upgrades
# TODO: reintroduce these at a later state
#var upgrade_javelin = preload("res://resources/upgrades/javelin.tres")
#var upgrade_javelin_damage = preload("res://resources/upgrades/javelin_damage.tres")
#var upgrade_javelin_rate = preload("res://resources/upgrades/javelin_rate.tres")
#var upgrade_javelin_quantity = preload("res://resources/upgrades/javelin_quantity.tres")

# anvil ability and upgrades
var upgrade_anvil = preload("res://resources/upgrades/anvil.tres")
var upgrade_anvil_quantity = preload("res://resources/upgrades/anvil_quantity.tres")
var upgrade_anvil_damage = preload("res://resources/upgrades/anvil_damage.tres")

# hammer upgrades
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")

var upgrade_screen_instance: CanvasLayer

func _ready() -> void:
	# Abilities
	upgrade_pool.add_item(upgrade_axe, 10)
	upgrade_pool.add_item(upgrade_hammer, 10)
	upgrade_pool.add_item(upgrade_dagger, 10)
	#upgrade_pool.add_item(upgrade_javelin, 10)
	upgrade_pool.add_item(upgrade_anvil, 10)
	
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 15)
	upgrade_pool.add_item(upgrade_player_speed, 7)
	GameEvents.game_over.connect(on_game_over)
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
	elif chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_damage, 12)
		upgrade_pool.add_item(upgrade_hammer_rate, 10)
	elif chosen_upgrade.id == upgrade_dagger.id:
		upgrade_pool.add_item(upgrade_dagger_damage, 12)
		upgrade_pool.add_item(upgrade_dagger_rate, 10)
		upgrade_pool.add_item(upgrade_dagger_quantity, 10)
	#elif chosen_upgrade.id == upgrade_javelin.id:
		#upgrade_pool.add_item(upgrade_javelin_damage, 12)
		#upgrade_pool.add_item(upgrade_javelin_rate, 10)
		#upgrade_pool.add_item(upgrade_javelin_quantity, 10)
	elif chosen_upgrade.id == upgrade_anvil.id:
		upgrade_pool.add_item(upgrade_anvil_damage, 12)
		upgrade_pool.add_item(upgrade_anvil_quantity, 10)


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
	if GameEvents.is_game_over:
		return
	upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func on_game_over() -> void:
	if upgrade_screen_instance == null:
		return
	
	upgrade_screen_instance.queue_free()

