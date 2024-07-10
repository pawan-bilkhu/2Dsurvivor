extends Node

@export var base_range: float = 150
@export var anvil_ability_scene: PackedScene

@onready var timer: Timer = $Timer

var base_damage: float = 15
var additional_damage_percent: float = 1
var base_wait_time: float
var anvil_quantity: int = 0

func _ready() -> void:
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	var additional_rotation = TAU / (anvil_quantity + 1)
	var anvil_distance = randf_range(0, base_range)
	
	for i in anvil_quantity + 1:
		
		var adjusted_direction = direction.rotated(i * additional_rotation)
		
		var spawn_position = player.global_position + adjusted_direction*anvil_distance
		
		var query_parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1 << 0)
		var result: Dictionary = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if not result.is_empty():
			spawn_position = result["position"]
		
		var foreground = get_tree().get_first_node_in_group("foreground_layer")
		if not foreground:
			return
			
		
		var anvil_ability = anvil_ability_scene.instantiate() as AnvilAbility
		foreground.add_child(anvil_ability)
			
		anvil_ability.hitbox_component.damage = base_damage
		anvil_ability.global_position = spawn_position


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "anvil_quantity":
		anvil_quantity = current_upgrades["anvil_quantity"]["quantity"]

