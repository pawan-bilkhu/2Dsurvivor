extends Area2D
class_name HitboxComponent

var damage: float = 0 : set = set_damage, get = get_damage
var critical_chance: float = 0: set = set_critical_chance, get = get_critical_chance
var critical_damage: float = 0: set = set_critical_damage, get = get_critical_damage


func set_damage(current_damage: float) -> void:
	damage = current_damage


func get_damage() -> float:
	return damage


func set_critical_chance(chance: float) -> void:
	critical_chance = chance


func get_critical_chance() -> float:
	return critical_chance


func set_critical_damage(damage: float) -> void:
	critical_damage = damage


func get_critical_damage() -> float:
	return critical_damage
