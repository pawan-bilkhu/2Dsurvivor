extends Node2D
class_name SwordAbility



@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var shadow_node_2d: Node2D = $ShadowNode2D



func set_shadow_properties(current_position: Vector2, current_rotation: float) -> void:
	var background_layer: Node2D = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	remove_child(shadow_node_2d)
	background_layer.add_child(shadow_node_2d)
	shadow_node_2d.rotation = current_rotation
	shadow_node_2d.global_position = current_position + 12*Vector2.DOWN


func destroy() -> void:
	shadow_node_2d.queue_free()
	queue_free()
