extends Node

signal game_over

signal experience_vial_collected(number: float)

signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal meta_upgrade_purchased

signal player_damaged
signal player_dashed(dash_duration: float)
signal player_dash_cooldown(wait_time: float)
signal player_current_health_updated

signal camera_shake(global_position: Vector2)

signal damage_dealt(damage_amount: float)

signal wave_change(current_wave: int)

var is_game_over: bool = false

func emit_experience_vial_collected(number: float) -> void:
	experience_vial_collected.emit(number)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_meta_upgrade_purchased() -> void:
	meta_upgrade_purchased.emit()


func emit_player_damaged() -> void:
	player_damaged.emit()


func emit_player_dashed(dash_duration: float) -> void:
	player_dashed.emit(dash_duration)


func emit_player_dash_cooldown(wait_time: float) -> void:
	player_dash_cooldown.emit(wait_time)


func emit_player_current_health_updated(current_health: float) -> void:
	player_current_health_updated.emit(current_health)


func emit_camera_shake(global_positon: Vector2) -> void:
	camera_shake.emit(global_positon)


func emit_damage_dealt(damage_amount: float) -> void:
	damage_dealt.emit(damage_amount)


func emit_wave_change(current_wave: int) -> void:
	wave_change.emit(current_wave)


# Helper method to find nearest groups within a given range
func get_enemy_count() -> int:
	var enemy_count: int = get_tree().get_nodes_in_group("enemy").size()
	return enemy_count


func emit_game_over() -> void:
	is_game_over = true
	game_over.emit()


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


