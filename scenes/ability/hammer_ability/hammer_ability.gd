extends Node2D
class_name HammerAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var visuals: Node2D = $Visuals



func set_facing_direction(direction: int) -> void:
	if abs(direction) > 1 or direction == 0:
		return
	visuals.scale.x = direction


func emit_camera_shake() -> void:
	GameEvents.emit_camera_shake(global_position)
