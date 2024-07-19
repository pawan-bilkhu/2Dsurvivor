extends Node2D
class_name AxeAbility

const MAX_RADIUS = 100

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D

var base_rotation: Vector2

func _ready() -> void:
	var background_layer: Node = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	
	shadow_sprite.scale = Vector2(1.75, 1)
	shadow_sprite.offset = Vector2(0, -1)
	
	
	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3.0)
	tween.tween_callback(destroy)


func tween_method(rotations: float) -> void:
	var percent: float = (rotations / 2)
	var current_radius: float = percent * MAX_RADIUS
	var current_direction: Vector2 = base_rotation.rotated(rotations * TAU)
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	global_position = player.global_position + (current_direction * current_radius)
	shadow_sprite.global_position = global_position
	shadow_sprite.position -= Vector2(0, -10)


func destroy() -> void:
	shadow_sprite.queue_free()
	queue_free()
