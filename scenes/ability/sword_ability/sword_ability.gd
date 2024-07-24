extends Node2D
class_name SwordAbility



@onready var hitbox_component: HitboxComponent = $HitboxComponent

var shadow_instance: Node2D


func destroy() -> void:
	shadow_instance.queue_free()
	queue_free()
	
