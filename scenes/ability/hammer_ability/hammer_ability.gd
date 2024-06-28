extends Node2D
class_name HammerAbility

@onready var hitbox_component: HitboxComponent = $Contents/HitboxComponent
@onready var visuals: Node2D = $Contents/Visuals



func set_facing_direction(direction: int) -> void:
	if abs(direction) > 1 or direction == 0:
		return
	visuals.scale.x = direction


func emit_hammer_smash() -> void:
	GameEvents.emit_hammer_smash(global_position)
