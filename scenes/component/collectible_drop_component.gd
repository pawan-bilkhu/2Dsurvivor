extends Node

@export_range(0, 1) var drop_percent: float = 0.5
@export var quantity: int = 1
@export var health_component: Node
@export var experience_vial_scene: PackedScene
@export var large_experience_vial_scene: PackedScene
@export var health_vial_scene: PackedScene
@export var large_health_vial_scene: PackedScene

@export var can_spawn_health: bool = false

var vial_weighted_table: WeightedTable = WeightedTable.new()

func _ready() -> void:
	(health_component as HealthComponent).died.connect(on_died)
	vial_weighted_table.add_item(experience_vial_scene, 17)
	vial_weighted_table.add_item(large_experience_vial_scene, 7)


func on_died() -> void:
	var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	
	#var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	#
	#if player.health_component.get_health_percent() < 1.0:
		#can_spawn_health = true
	
	var adjusted_drop_percent = drop_percent*(1+0.1*experience_gain_upgrade_count)
	
	if not owner is Node2D:
		return
	
	if randf() > adjusted_drop_percent:
			return
	
	
	if can_spawn_health:
		if randf() < 0.5:
			create_vial(health_vial_scene, (owner as Node2D).global_position + 10*Vector2.RIGHT.rotated(randf_range(0, TAU)))
		else:
			create_vial(large_health_vial_scene, (owner as Node2D).global_position + 10*Vector2.RIGHT.rotated(randf_range(0, TAU)))
 		#vial_weighted_table.add_item(health_vial_scene, 8)
		#vial_weighted_table.add_item(large_health_vial_scene, 5)
	
	for i in quantity:
		create_vial(vial_weighted_table.pick_item(), (owner as Node2D).global_position + 10*Vector2.RIGHT.rotated(randf_range(0, TAU)))

	
func create_vial(vial_scene: PackedScene, spawn_position: Vector2) -> void:
	var vial_instance: Node2D = vial_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(vial_instance)
	vial_instance.global_position = spawn_position
