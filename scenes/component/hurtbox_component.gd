extends Area2D
class_name HurtboxComponent

signal hit

@export var heatlh_component: Node
@export var floating_text_scene: PackedScene


func _on_area_entered(area: Area2D) -> void:
	if not area is HitboxComponent:
		return
	
	if not heatlh_component:
		return
	
	var hitbox_component = area as HitboxComponent
	
	heatlh_component.damage(hitbox_component.damage)
	
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	floating_text.global_position = global_position + (Vector2.UP*16)
	
	var format_string: String = "%0.1f" 
	if round(hitbox_component.damage) == hitbox_component.damage:
		format_string = "%0.0f"
	floating_text.start(format_string % hitbox_component.damage)
	
	if hitbox_component.is_in_group("throwable"):
		hitbox_component.owner.destroy()
	
	hit.emit()
