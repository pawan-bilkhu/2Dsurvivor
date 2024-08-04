extends CharacterBody2D
class_name BaseEnemy

@export var dash_strength: float = 2.75

@onready var visuals: Node2D = $Visuals
@onready var velocity_component: Node = $VelocityComponent
@onready var hit_random_audio_player_2d_component: AudioStreamPlayer2D = $HitRandomAudioPlayer2DComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = %HealthBar


var is_dashing: bool = false
var can_dash: bool = false
var movement_vector: Vector2
var direction_vector: Vector2
var current_dash_strength: float

func _ready() -> void:
	hurtbox_component.hit.connect(on_hit)
	hurtbox_component.knockback.connect(on_knockback)
	health_component.health_changed.connect(on_health_changed)
	update_health_bar()


func _process(delta: float) -> void:
	movement_vector = velocity_component.get_player_direction()
	
	if not is_dashing:
		direction_vector = movement_vector.normalized()
		velocity_component.accelerate_in_direction(direction_vector)
	
	check_dash(dash_strength)
	
	if is_dashing:
		velocity_component.dash_in_direction(direction_vector, current_dash_strength)
		
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)



func check_dash(dash_strength: float) -> void:
	if not can_dash || is_dashing:
		return
	set_can_dash(false)
	set_is_dashing(true)
	var dash_duration: float = 0.1
	current_dash_strength = dash_strength
	get_tree().create_timer(dash_duration).timeout.connect(set_is_dashing.bind(false))


func on_health_changed() -> void:
	update_health_bar()


func update_health_bar() -> void:
	health_bar.value = health_component.get_health_percent()


func on_hit() -> void:
	hit_random_audio_player_2d_component.play_random()


func get_can_dash() -> bool:
	return can_dash


func set_can_dash(value: bool) -> void:
	can_dash = value


func get_is_dashing() -> bool:
	return is_dashing


func set_is_dashing(value: bool) -> void:
	is_dashing = value


func on_knockback(direction) -> void:
	direction_vector = direction
	set_can_dash(true)
	check_dash(0.75*dash_strength)
	

