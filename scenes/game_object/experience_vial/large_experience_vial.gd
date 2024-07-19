extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var random_stream_player_2d_component: AudioStreamPlayer2D = $RandomStreamPlayer2DComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func tween_collect(percent: float, start_position: Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start: Vector2 = player.global_position - start_position
	var target_rotation: float = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))


func collect() -> void:
	GameEvents.emit_experience_vial_collected(4)
	queue_free()


func disable_collision() -> void:
	collision_shape_2d.disabled = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	Callable(disable_collision).call_deferred()
	animation_player.stop()
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.1).set_delay(.41)
	tween.chain()
	tween.tween_callback(collect)
	random_stream_player_2d_component.play_random()

