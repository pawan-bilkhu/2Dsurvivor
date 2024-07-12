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
	
	var damage_amount = hitbox_component.damage
	var critical_damage = 0
	
	if randf() <= hitbox_component.critical_chance:
		critical_damage = hitbox_component.critical_damage * damage_amount
	
	damage_amount += critical_damage
	heatlh_component.damage(damage_amount)
	
	
	var floating_damage_text = floating_text_scene.instantiate() as Node2D
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	if critical_damage > 0:
		floating_damage_text.set_critical_text()
	foreground_layer.add_child(floating_damage_text)
	floating_damage_text.global_position = global_position + (Vector2.UP*16)
	floating_damage_text.start(format_string(damage_amount))
	
	
	if hitbox_component.is_in_group("javelin"):
		hitbox_component.owner.destroy()
	
	hit.emit()


func format_string(value: float) -> String:
	var formatted_string: String = "%0.1f" 
	if round(value) == value:
		formatted_string = "%0.0f"
	return (formatted_string % value)
