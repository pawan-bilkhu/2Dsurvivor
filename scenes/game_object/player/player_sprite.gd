extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var health_bar: ProgressBar = $HealthBar

const ACCELERATION_SMOOTHING = 25
const MAX_SPEED: float = 150.0

var number_colliding_bodies: int = 0


func _ready() -> void:
	health_component.health_changed.connect(on_health_changed)
	update_health_display()


func _process(delta: float) -> void:
	var direction_vector: Vector2 = get_movement_vector().normalized()
	var target_velocity = direction_vector*MAX_SPEED
	
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING)) 
	move_and_slide()


func get_movement_vector() -> Vector2:
	var direction_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var direction_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(direction_x, direction_y)


func check_deal_damage() -> void:
	if number_colliding_bodies == 0 or not damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()
	print(health_component.current_health)


func update_health_display() -> void:
	health_bar.value = health_component.get_health_percent()


func on_health_changed() -> void:
	update_health_display()


func _on_collision_area_2d_body_entered(body: Node2D) -> void:
	number_colliding_bodies += 1
	check_deal_damage()


func _on_collision_area_2d_body_exited(body: Node2D) -> void:
	number_colliding_bodies -= 1


func _on_damage_interval_timer_timeout() -> void:
	check_deal_damage()
