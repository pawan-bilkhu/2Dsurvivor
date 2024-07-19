extends CharacterBody2D


@onready var velocity_component: Node = $VelocityComponent
@onready var visuals: Node2D = $Visuals
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hit_random_audio_player_2d_component: AudioStreamPlayer2D = $HitRandomAudioPlayer2DComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar

var is_moving: bool = false

func _ready() -> void:
	hurtbox_component.hit.connect(on_hit)
	health_component.health_changed.connect(on_health_changed)
	update_health_bar()


func _process(delta: float) -> void:
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
	
	velocity_component.move(self)
	
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func on_health_changed() -> void:
	update_health_bar()


func update_health_bar() -> void:
	health_bar.value = health_component.get_health_percent()


func set_is_moving(moving: bool) -> void:
	is_moving = moving


func on_hit() -> void:
	hit_random_audio_player_2d_component.play_random()
