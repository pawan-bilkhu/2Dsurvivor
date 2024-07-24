extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
var animation_speed: float = 0.0


func _ready() -> void:
	(sprite.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)


func start(animation_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(5, 2), 0)
	
	tween.set_parallel()
	tween.tween_property(sprite.material, "shader_parameter/lerp_percent", 0.0, animation_duration)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(sprite, "scale", Vector2(1.3, 1), animation_duration)
	tween.chain()
	tween.tween_callback(queue_free)


