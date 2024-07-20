extends Node

@export_range(0, 1) var drop_percent: float = 0.5
@export var health_component: Node
@export var experience_vial_scene: PackedScene
@export var large_experience_vial_scene: PackedScene
@export var health_vial_scene: PackedScene

func _ready() -> void:
	(health_component as HealthComponent).died.connect(on_died) 


func on_died() -> void:
	var experience_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	
	var adjusted_drop_percent = drop_percent*(1+0.1*experience_gain_upgrade_count)
	
	
	if randf() > adjusted_drop_percent:
		return
	
	if not experience_vial_scene:
		return
	
	if not owner is Node2D:
		return
	
	var spawn_position = (owner as Node2D).global_position
	var vial_instance: Node2D
	if randf() <= 0.5:
		if randf() <= 0.8:
			vial_instance = experience_vial_scene.instantiate() as Node2D
		else: 
			vial_instance = large_experience_vial_scene.instantiate() as Node2D
	else:
		vial_instance = health_vial_scene.instantiate() as Node2D
		
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(vial_instance)
	vial_instance.global_position = spawn_position
