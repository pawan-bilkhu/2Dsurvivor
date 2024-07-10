extends Node

const SAVE_FILE_PATH = "user://weapon_stats.json"

var weapon_stats: Dictionary = {
	"weapons": {
		"sword" : { 
			"base_damage" : 5.0,
			"critical_chance" : 0.05,
			"critical_damage" : 1.0,
			"attack_interval" :  3.0,
			"upgrade_quantity" : 0,
		},
		"axe" : { 
			"base_damage" : 7.0,
			"critical_chance" : 0.10,
			"critical_damage" : 1.5,
			"attack_interval" :  5.0,
			"upgrade_quantity" : 0,
		},
		"hammer" : { 
			"base_damage" : 15.0,
			"critical_chance" : 0.10,
			"critical_damage" : 2.0,
			"attack_interval" :  8.0,
			"upgrade_quantity" : 0,
		}
		
	}
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


func update_weapon_stats(upgrade: WeaponUpgrade) -> void:
	var stats = get_weapon_stats(upgrade.id)
	if stats.is_empty():
		print("Could not upgrade non-existent weapon")
		return
	
	stats["base_damage"] += upgrade.damage_increase
	stats["critical_chance"] += upgrade.critcal_chance_increase
	stats["critical_damage"] += upgrade.critcal_damage_increase
	stats["attack_interval"] -= upgrade.attack_interval_decrease
	stats["upgrade_quantity"] += 1
		
	weapon_stats["weapons"][upgrade.id] = stats
	save_weapon_stats()


func get_weapon_stats(upgrade_id: String) -> Dictionary:
	var stats: Dictionary = { }
	if weapon_stats["weapons"].has(upgrade_id):
		stats = weapon_stats["weapons"][upgrade_id]
	return stats
