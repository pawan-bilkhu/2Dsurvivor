extends Node2D
class_name AxeAbility

const MAX_RADIUS = 75.0


var current_radius: float = 0.0
var rotation_rate: float = PI
var spin_duration: float = 20.0
var changing_radius: bool = false

signal died

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var shadow_sprite: Sprite2D = $ShadowSprite2D
@onready var sprite: Sprite2D = $Sprite2D

var base_rotation: Vector2

func _ready() -> void:
	
	var tween = create_tween()
	tween.tween_method(tween_evaporate, 0.0, 0.0, 0)
	tween.tween_method(tween_evaporate, 0.0, 1.0, 0.4)
	
	
	if changing_radius:
		tween = create_tween().set_loops()
		tween.tween_method(tween_distance, 0.4, 1.0, 1.0)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_interval(2.0)
		tween.tween_method(tween_distance, 1.0, 0.4, 1.0)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_interval(2.0)
	
	var background_layer: Node = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	
	shadow_sprite.scale = Vector2(1.25, 1)
	shadow_sprite.offset = Vector2(0, 1)
	
	
	get_tree().create_timer(spin_duration).timeout.connect(on_timeout)
	
	
	#tween.tween_callback(destroy)


func _process(delta: float) -> void: 
	base_rotation = base_rotation.rotated(rotation_rate*delta)
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	global_position = player.marker_2d.global_position + (base_rotation * current_radius)
	shadow_sprite.global_position = global_position
	shadow_sprite.position += Vector2(0, 15)


func tween_distance(percent: float) -> void:
	current_radius = percent*MAX_RADIUS


func tween_evaporate(percent: float) -> void:
	sprite.self_modulate.a = percent
	shadow_sprite.self_modulate.a = 0.80*percent
	

func destroy() -> void:
	died.emit()
	shadow_sprite.queue_free()
	queue_free()


func on_timeout() -> void:
	var tween = create_tween()
	tween.tween_method(tween_evaporate, 1.0, 0.0, 0.2)
	tween.tween_callback(destroy)
