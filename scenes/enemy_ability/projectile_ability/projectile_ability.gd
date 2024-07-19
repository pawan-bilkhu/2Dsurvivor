extends Node2D


const GRAVITY: float = 9.8

signal landed

@onready var outer_gpu_particles_2d: GPUParticles2D = %OuterGPUParticles2D
@onready var inner_gpu_particles_2d: GPUParticles2D = %InnerGPUParticles2D

@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var visuals: Node2D = $Visuals

var scale_factor: float = 0.5

var initial_speed: float 
var intial_angle : float

var time: float = 0.0
var starting_position: Vector2
var target_position: Vector2
var target_direction: Vector2

var z_axis: float = 0.0
var has_launched: bool = false

var simulation_speed: float = 10.0

func _ready() -> void:
	landed.connect(on_landed)
	
	outer_gpu_particles_2d.emitting = true
	inner_gpu_particles_2d.emitting = true
	shadow_sprite.scale = scale_factor * Vector2.ONE
	
	var background_layer = get_tree().get_first_node_in_group("background_layer")
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)
	
	
	#var tween = create_tween()
	#tween.set_parallel()
	#tween.tween_property(self, "global_position", target_position, 3.0)
	#tween.tween_method(tween_method.bind(target_direction), 0.0, 1.0, 5.0)\
	#.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	#tween.tween_property(self, "scale", Vector2.ZERO, 0.2).set_delay(0.8)
	#tween.chain()
	#tween.tween_callback(destroy)
	#

#func tween_method(percent: float, target_direction: Vector2) -> void:
	#global_position = global_position.lerp(target_direction, percent)
	#shadow_sprite.global_position = global_position
	#shadow_sprite.scale = scale


func _process(delta: float) -> void:
	time += delta * simulation_speed
	
	if has_launched:
		z_axis = initial_speed * sin(intial_angle) * time - 0.5 * GRAVITY * pow(time, 2)
		
		if z_axis > 0:
			var x_axis: float = initial_speed * cos(intial_angle) * time
			global_position = starting_position + target_direction * x_axis
			shadow_sprite.global_position = global_position
			shadow_sprite.scale = Vector2(0.5, 0.25) * (1 + (1 - exp(-z_axis)))
			visuals.position.y = -z_axis
		else:
			has_launched = false
			landed.emit()


func on_landed() -> void:
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(shadow_sprite, "scale", Vector2.ZERO, 0.2)
	tween.chain()
	tween.tween_callback(destroy)


func launch_projectile(initial_position: Vector2, direction: Vector2, desired_distance: float, desired_angle: float) -> void:
	starting_position = initial_position
	target_direction = direction.normalized()
	intial_angle = desired_angle
	
	initial_speed = pow(desired_distance * GRAVITY / sin(2 * desired_angle), 0.5)
	
	global_position = starting_position
	shadow_sprite.global_position = global_position
	time = 0.0
	z_axis = 0
	has_launched = true


func destroy() -> void:
	shadow_sprite.queue_free()
	queue_free()
