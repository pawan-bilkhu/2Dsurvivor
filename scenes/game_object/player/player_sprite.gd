extends CharacterBody2D

@export var arena_time_manager: Node

@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var health_bar: ProgressBar = $HealthBar
@onready var abilities: Node = $Abilities
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var velocity_component: Node = $VelocityComponent
@onready var hit_random_stream_player_2d_component: AudioStreamPlayer2D = $HitRandomStreamPlayer2DComponent


var number_colliding_bodies: int = 0
var base_speed: float = 0.0


func _ready() -> void:
	health_component.set_max_health(health_component.max_health * (1 + MetaProgression.get_upgrade_count("health_maximum")))
	# print(health_component.current_health)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	health_component.health_decreased.connect(on_health_decreased)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()


func _process(delta: float) -> void:
	var movement_vector = get_movement_vector()
	var direction_vector: Vector2 = movement_vector.normalized()
	velocity_component.accelerate_in_direction(direction_vector)
	velocity_component.move(self)
	
	if movement_vector.length_squared() > 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
	
	var move_sign: int = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)


func get_movement_vector() -> Vector2:
	var direction_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var direction_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(direction_x, direction_y)


func check_deal_damage() -> void:
	if number_colliding_bodies == 0 or not damage_interval_timer.is_stopped():
		return
	health_component.damage(1)
	damage_interval_timer.start()
	# print(health_component.current_health)


func update_health_display() -> void:
	health_bar.value = health_component.get_health_percent()


func on_health_decreased() -> void:
	GameEvents.emit_player_damaged()
	hit_random_stream_player_2d_component.play_random()


func on_health_changed() -> void:
	update_health_display()


func _on_collision_area_2d_body_entered(body: Node2D) -> void:
	number_colliding_bodies += 1
	check_deal_damage()


func _on_collision_area_2d_body_exited(body: Node2D) -> void:
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
		var percent_increase = current_upgrades["player_speed"]["quantity"] * 0.2
		velocity_component.max_speed = base_speed*(1 + percent_increase)
