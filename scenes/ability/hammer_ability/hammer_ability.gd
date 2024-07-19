extends Node2D
class_name HammerAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var visuals: Node2D = $Visuals
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D


#func _ready() -> void:
	#var background_layer = get_tree().get_first_node_in_group("background_layer")
	#remove_child(shadow_sprite)
	#background_layer.add_child(shadow_sprite)
	#
	#shadow_sprite.global_position = global_position


func set_facing_direction(direction: int) -> void:
	if abs(direction) > 1 or direction == 0:
		return
	visuals.scale.x = direction


func emit_camera_shake() -> void:
	GameEvents.emit_camera_shake(global_position)


func destroy() -> void:
	shadow_sprite.queue_free()
	queue_free()
