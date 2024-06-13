extends Node

@export var axe_ability_scene: PackedScene

var damage: int = 10


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if not foreground_layer:
		return
	
	var axe_ability_instance = axe_ability_scene.instantiate() as Node2D
	foreground_layer.add_child(axe_ability_instance)
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.hitbox_component.damage = damage
