extends Node

signal experience_vial_collected(number: float)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal camera_shake(global_position: Vector2)


func emit_experience_vial_collected(number: float) -> void:
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged() -> void:
	player_damaged.emit()


func emit_camera_shake(global_positon: Vector2) -> void:
	camera_shake.emit(global_positon)


func nearest_target_group(group: StringName, target: Node2D, max_range: float) -> Array:
	if not target:
		return []
	
	var entity_group = get_tree().get_nodes_in_group(group)
	
		
	entity_group = entity_group.filter(func(entity: CharacterBody2D): 
		return entity.global_position.distance_squared_to(target.global_position) < pow(max_range, 2)	
	)
	
	if entity_group.size() == 0:
		return []
	
	entity_group.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(target.global_position)
		var b_distance = b.global_position.distance_squared_to(target.global_position)
		return a_distance < b_distance
	)
	
	return entity_group

