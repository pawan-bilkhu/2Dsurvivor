extends Node

const SAVE_FILE_PATH = "user://weapon_stats.save"
const RESOURCE_SAVE_FILE = "user://weapon_stats_resource.save"

@export var sword_stats: WeaponStats = WeaponStats.new()
@export var axe_stats: WeaponStats = WeaponStats.new()
@export var hammer_stats: WeaponStats = WeaponStats.new()
@export var dagger_stats: WeaponStats = WeaponStats.new()
@export var javelin_stats: WeaponStats = WeaponStats.new()
@export var anvil_stats: WeaponStats = WeaponStats.new()

var weapon_stats_resources: Dictionary


var weapon_stats: Dictionary = {
	"sword" : {
		"damage" : {
			"magnitude" : 2.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude" : 0.05,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude": 1.0,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" :  {
			"magnitude": 1.75,
			"current_upgrade_quantity" : 0,
		},
	},
	"axe" : {
		"damage" : {
			"magnitude": 4.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude" : 0.08,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude" : 1.15,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" : {
			"magnitude" : 7.0,
			"current_upgrade_quantity" : 0,
		},	
	},
 	"hammer" : {
		"damage" : { 
			"magnitude" : 6.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude": 0.12,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude" : 2.0,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" :  {
			"magnitude" : 4.0,
			"current_upgrade_quantity" : 0,
		},
	},
	"dagger" : {
		"damage" : { 
			"magnitude" : 4.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude": 0.03,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude" : 1.1,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" :  {
			"magnitude" : 3.0,
			"current_upgrade_quantity" : 0,
		},
	},
	"javelin" : {
		"damage" : { 
			"magnitude" : 3.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude": 0.05,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude" : 1.05,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" :  {
			"magnitude" : 5.0,
			"current_upgrade_quantity" : 0,
		},
	},
	"anvil" : {
		"damage" : { 
			"magnitude" : 8.0,
			"current_upgrade_quantity" : 0,
		},
		"critical_chance" : {
			"magnitude": 0.14,
			"current_upgrade_quantity" : 0,
		},
		"critical_damage" : {
			"magnitude" : 2.5,
			"current_upgrade_quantity" : 0,
		},
		"attack_interval" :  {
			"magnitude" : 12.0,
			"current_upgrade_quantity" : 0,
		},
	},
}


func _ready() -> void:
	load_weapon_stats_resource(sword_stats)
	load_weapon_stats_resource(axe_stats)
	load_weapon_stats_resource(hammer_stats)
	load_weapon_stats_resource(dagger_stats)
	load_weapon_stats_resource(javelin_stats)
	load_weapon_stats_resource(anvil_stats)


# weapon stats as dictionary
func load_weapon_stats() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		save_weapon_stats()
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	weapon_stats = file.get_var()


func save_weapon_stats() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(weapon_stats)


func add_weapon_stat(weapon_id: String, stat_id: String, stat_value: float) -> void:
	var stats = get_weapon_stats(weapon_id)
	if stats.is_empty():
		print("Could not upgrade non-existent weapon")
		return
	
	stats[stat_id]["magnitude"] += stat_value
	stats[stat_id]["current_upgrade_quantity"] += 1
	
	weapon_stats[weapon_id] = stats
	save_weapon_stats()


func get_weapon_stats(weapon_id: String) -> Dictionary:
	var stats: Dictionary = { }
	if weapon_stats.has(weapon_id):
		stats = weapon_stats[weapon_id]
	return stats


# weapon stats as a resource
func load_weapon_stats_resource(weapon_resource: WeaponStats) -> void:
	var save_path = get_save_path(weapon_resource.id)
	if ResourceLoader.exists(save_path):
		var loaded_resource: Resource = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		weapon_stats_resources[weapon_resource.id] = loaded_resource
		print(save_path + " loaded")
	else:
		weapon_stats_resources[weapon_resource.id] = weapon_resource
		save_weapon_stats_resource(weapon_resource)


func save_weapon_stats_resource(weapon_resource: WeaponStats) -> void:
	ResourceSaver.save(weapon_resource, get_save_path(weapon_resource.id))


func get_weapon_stats_resource(weapon_id: String) -> WeaponStats:
	var stats: WeaponStats = null
	if weapon_stats_resources.has(weapon_id):
		stats = weapon_stats_resources[weapon_id]
	return stats


func get_save_path(weapon_id: String) -> String:
	var path: String = "user://%s_stats.tres" % [weapon_id]
	return path
