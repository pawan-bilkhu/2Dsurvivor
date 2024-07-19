extends Node

const SAVE_FILE_PATH = "user://weapon_stats.json"

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
			"magnitude" : 10.0,
			"current_upgrade_quantity" : 0,
		},
	},
	"dagger" : {
		"damage" : { 
			"magnitude" : 1.0,
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
			"magnitude" : 1.0,
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
	load_weapon_stats()


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
