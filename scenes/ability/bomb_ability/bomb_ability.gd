extends Node2D

const GRAVITY: float = 150.0

signal landed

@onready var shadow_sprite: Sprite2D = $ShadowSprite2D
@onready var visuals: Node2D = $Visuals



@export var horizontal_speed: float = 200.0
@export var vertical_speed: float = -100.0



var bomb_stats: WeaponStats : set = set_bomb_stats, get = get_bomb_stats

var explosion_scene: PackedScene = preload("res://scenes/game_object/explosion/explosion.tscn")
var fire_aoe_scene: PackedScene = preload("res://scenes/game_object/fire_aoe/fire_aoe.tscn")

var initial_speed: float 
var intial_angle : float

var time: float = 0.0
var starting_position: Vector2

var target_direction: Vector2

var z_axis: float = 0.0
var has_launched: bool = false

var simulation_speed: float = 1.0

func _ready() -> void:
	landed.connect(explode)
	var background_layer: Node2D = get_tree().get_first_node_in_group("background_layer")
	
	remove_child(shadow_sprite)
	background_layer.add_child(shadow_sprite)


func _process(delta: float) -> void:
	time += delta * simulation_speed
	
	if has_launched:
		z_axis = initial_speed * sin(intial_angle) * time - 0.5 * GRAVITY * pow(time, 2)
		
		if z_axis > 0:
			var x_axis: float = initial_speed * cos(intial_angle) * time
			global_position = starting_position + target_direction * x_axis
			shadow_sprite.global_position = global_position
			#shadow_sprite.scale = Vector2(0.5, 0.25) * (1 + (1 - exp(-z_axis)))
			visuals.position.y = -z_axis
		else:
			has_launched = false
			landed.emit()


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


func set_bomb_stats(stats: WeaponStats) -> void:
	bomb_stats = stats


func get_bomb_stats() -> WeaponStats:
	return bomb_stats


func explode() -> void:
	var background_layer: Node2D = get_tree().get_first_node_in_group("background_layer") as Node2D
	var foreground_layer: Node2D = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	
	var explosion_instance: Node2D = explosion_scene.instantiate() as Node2D
	var fire_aoe_instance: Node2D = fire_aoe_scene.instantiate() as Node2D
	
	background_layer.add_child(explosion_instance)
	foreground_layer.add_child(fire_aoe_instance)
	explosion_instance.global_position = global_position
	fire_aoe_instance.global_position = global_position
	
	queue_free()
	shadow_sprite.queue_free()
