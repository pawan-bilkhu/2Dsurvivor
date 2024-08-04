extends CharacterBody2D

const MAX_RADIUS: float = 150.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D
@onready var sprite: Sprite2D = $Sprite2D


var tween: Tween
var target_position: Vector2
var target_enemy: Node2D
var speed: float = 175.0
var is_dead: bool = false
var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	tween = create_tween()
	tween.tween_method(tween_evaporate, 0.0, 0.0, 0)
	tween.tween_method(tween_evaporate, 0.0, 1.0, 0.2)
	
	var background_layer = get_tree().get_first_node_in_group("background_layer")
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	
	
	
	direction = target_position - global_position
	global_position += 2*direction.normalized()
	
	shadow_sprite.global_position = global_position
	shadow_sprite.scale = Vector2(1, 1.0)



func _process(delta: float) -> void:
	velocity = speed*direction.normalized()

	rotation = velocity.angle()
	
	
	shadow_sprite.global_position = global_position
	shadow_sprite.position += Vector2(0, 10)
	
	shadow_sprite.rotation = rotation + PI/2
	
	
	if is_on_wall() || is_on_ceiling() || is_on_floor():
		destroy()
	
	move_and_slide()
	
	if not target_enemy:
		return
	
	target_position = target_enemy.global_position
	direction = target_position - global_position

func tween_evaporate(percent: float) -> void:
	sprite.self_modulate.a = percent
	shadow_sprite.self_modulate.a = 0.8*percent


func destroy() -> void:
	if is_dead:
		return
	is_dead = true
	tween.kill()
	shadow_sprite.queue_free()
	queue_free()


