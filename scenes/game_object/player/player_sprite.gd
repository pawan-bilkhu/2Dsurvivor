extends CharacterBody2D


enum PlayerStates { 
	WALK,
	IDLE,
	DASH,
	}


@export var arena_time_manager: Node

@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var abilities: Node = $Abilities
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var velocity_component: Node = $VelocityComponent
@onready var hit_random_stream_player_2d_component: AudioStreamPlayer2D = $HitRandomStreamPlayer2DComponent
@onready var marker_2d: Marker2D = $Marker2D

@onready var dash_timer: Timer = $DashTimer

var movement_vector: Vector2
var direction_vector: Vector2
var number_colliding_bodies: int = 0
var base_speed: float = 0.0
var is_dashing: bool = false
var can_dash: bool = true

var facing_direction: Vector2 = Vector2.UP
var current_state: PlayerStates = PlayerStates.IDLE


func _ready() -> void:
	health_component.set_max_health(health_component.max_health * (1 + MetaProgression.get_upgrade_count("health_maximum")))
	GameEvents.emit_player_current_health_updated(health_component.get_health_percent())
	# print(health_component.current_health)
	# arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	health_component.health_decreased.connect(on_health_decreased)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _process(delta: float) -> void:
	movement_vector = get_movement_vector()
	
	if not is_dashing:
		direction_vector = movement_vector.normalized()
	
	if direction_vector.length_squared() > 0:
		facing_direction = direction_vector
	
	
	check_dash()
	
	if get_is_dashing():
		velocity_component.dash_in_direction(direction_vector, 3.0)
	else:
		velocity_component.accelerate_in_direction(direction_vector)
	
	
	velocity_component.move(self)
	
	if movement_vector.length_squared() > 0:
		change_current_state(PlayerStates.WALK)
	else:
		change_current_state(PlayerStates.IDLE)
		
	
	set_current_animation()
	
	var move_sign: int = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func set_current_animation() -> void:
	if current_state == PlayerStates.WALK:
		animation_player.play("walk")
	elif current_state == PlayerStates.IDLE:
		animation_player.play("RESET")
	elif current_state == PlayerStates.DASH:
		animation_player.play("dash")


func change_current_state(new_state: PlayerStates) -> void:
	if new_state == current_state:
		return
	
	current_state = new_state


func get_facing_direction() -> Vector2:
	return facing_direction


func get_movement_vector() -> Vector2:
	var direction_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var direction_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(direction_x, direction_y)


func check_dash() -> void:
	if not can_dash || is_dashing || direction_vector == Vector2.ZERO:
		return
	if Input.is_action_just_pressed("dash"):
		change_current_state(PlayerStates.DASH)
		set_current_animation()
		set_can_dash(false)
		set_is_dashing(true)
		var dash_duration: float = 0.3
		
		GameEvents.emit_player_dashed(dash_duration)
		
		await get_tree().create_timer(dash_duration).timeout
		set_is_dashing(false)
		dash_timer.start()
		GameEvents.emit_player_dash_cooldown(dash_timer.wait_time)


func get_can_dash() -> bool:
	return can_dash


func set_can_dash(value: bool) -> void:
	can_dash = value


func get_is_dashing() -> bool:
	return is_dashing


func set_is_dashing(value: bool) -> void:
	is_dashing = value


func check_deal_damage() -> void:
	if number_colliding_bodies == 0 or not damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()
	# print(health_component.current_health)


func get_current_abilitis() -> Array:
	return abilities.get_children()


func on_health_decreased() -> void:
	GameEvents.emit_player_damaged()
	hit_random_stream_player_2d_component.play_random()


func on_health_changed() -> void:
	GameEvents.emit_player_current_health_updated(health_component.get_health_percent())


func heal(health_amount: float) -> void:
	health_component.heal(health_amount)


func _on_collision_area_2d_body_entered(body: Node2D) -> void:
	number_colliding_bodies += 1
	check_deal_damage()


func _on_collision_area_2d_body_exited(body: Node2D) -> void:
	number_colliding_bodies -= 1


func _on_collision_area_2d_area_entered(area: Area2D) -> void:
	number_colliding_bodies += 1
	check_deal_damage()

func _on_collision_area_2d_area_exited(area: Area2D) -> void:
	number_colliding_bodies -= 1


func _on_damage_interval_timer_timeout() -> void:
	check_deal_damage()


func on_arena_difficulty_increased(difficulty: int) -> void:
	var health_regen_quantity = MetaProgression.get_upgrade_count("health_regeneration")
	if health_regen_quantity > 0:
		var is_thirty_second_interval = (difficulty % 6) == 0
		if is_thirty_second_interval:
			health_component.heal(health_regen_quantity)


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if ability_upgrade is Ability:
		var new_ability = ability_upgrade.ability_controller_scene.instantiate()
		abilities.add_child(new_ability)
	elif ability_upgrade.id == "player_speed":
		var percent_increase = current_upgrades["player_speed"]["quantity"] * 0.05
		velocity_component.max_speed = base_speed*(1 + percent_increase)


func _on_dash_timer_timeout() -> void:
	set_can_dash(true)
