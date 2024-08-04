extends CharacterBody2D
class_name DaggerAbility


@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var collision_shape_2d: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D
@onready var visuals: Node2D = $Visuals


var speed: float = 50.0
var direction: Vector2
var can_move: bool = false
var is_dead: bool = false
var tween: Tween


func _ready() -> void:
	
	global_transform = Transform2D(direction.angle(), Vector2.ONE, 0, global_position)
	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.0)
	tween.chain()
	
	var background_layer: Node = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	shadow_sprite.global_transform = Transform2D(direction.angle() + PI/2, Vector2(1, 1.25), 0, global_position)
	shadow_sprite.self_modulate.a = 0.0
	
	tween.set_parallel()
	tween.tween_property(self, "scale", Vector2.ONE, 0.06)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(shadow_sprite, "self_modulate:a", 0.7, 0.06)
	tween.chain()
	tween.tween_callback(set_can_move.bind(true))


func _process(delta: float) -> void:
	shadow_sprite.global_position = global_position
	shadow_sprite.position += Vector2(0, 10)
	
	if not can_move:
		return
	
	velocity = speed*direction
	
	if is_on_wall() || is_on_ceiling() || is_on_floor():
		destroy()
	
	move_and_slide()


func set_can_move(value: bool) -> void:
	can_move = value


func set_direction(new_direction: Vector2) -> void:
	direction = new_direction


func enable_collision() -> void:
	collision_shape_2d.disabled = false


func destroy() -> void:
	if is_dead:
		return
	is_dead = true
	tween.kill()
	shadow_sprite.queue_free()
	queue_free()
