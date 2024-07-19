extends Node2D
class_name DaggerAbility

@export var target_position: Vector2
@export var radius: float = 70.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var collision_shape_2d: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D
@onready var visuals: Node2D = $Visuals





func _ready() -> void:
	visuals.position += 60*Vector2.UP
	global_position = target_position
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.0)
	
	
	var background_layer: Node = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	shadow_sprite.global_position = global_position
	shadow_sprite.scale = Vector2(1.5, 0.75)
	shadow_sprite.self_modulate.a = 0.0
	
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(shadow_sprite, "self_modulate:a", 0.6, 0.3)
	tween.chain()
	
	tween.set_parallel()
	tween.tween_method(tween_method.bind(visuals.position), 0.0 , 1.0, 0.4)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_delay(0.2)
	tween.tween_property(shadow_sprite, "scale", Vector2(1.0, 0.5), 0.4).set_delay(0.2)
	tween.tween_property(shadow_sprite, "self_modulate:a", 0.8, 0.2).set_delay(0.2)
	tween.chain()
	tween.tween_callback(enable_collision)
	
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(1.0)
	tween.tween_property(shadow_sprite, "scale", Vector2.ZERO, 0.4).set_delay(1.0)
	tween.chain()
	tween.tween_callback(destroy)


func tween_method(percent: float, start_position: Vector2) -> void:
	visuals.position = start_position.lerp(Vector2.ZERO, percent)
	shadow_sprite.global_position = global_position


func enable_collision() -> void:
	collision_shape_2d.disabled = false

func destroy() -> void:
	shadow_sprite.queue_free()
	queue_free()
