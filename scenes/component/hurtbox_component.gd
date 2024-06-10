extends Area2D
class_name HurtboxComponent

@export var heatlh_component: Node




func _on_area_entered(area: Area2D) -> void:
	if not area is HitboxComponent:
		return
	
	if not heatlh_component:
		return
	
	var hitbox_component = area as HitboxComponent
	
	heatlh_component.damage(hitbox_component.damage)
