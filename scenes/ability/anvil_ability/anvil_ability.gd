extends Node2D
class_name AnvilAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent


func emit_camera_shake() -> void:
	GameEvents.emit_camera_shake(global_position)
