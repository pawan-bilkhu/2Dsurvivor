extends Node
class_name VelocityComponent

@export var max_speed: int = 40
@export var acceleration: float = 5


var velocity: Vector2 = Vector2.ZERO

func accelerate_to_player() -> void:
	var direction: Vector2 = get_player_direction()
	accelerate_in_direction(direction)


func get_player_direction() -> Vector2:
	var owner_node_2d: Node2D = owner as Node2D
	if not owner_node_2d:
		return Vector2.ZERO
	
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return Vector2.ZERO
	
	var direction: Vector2 = (player.global_position - owner_node_2d.global_position).normalized()
	return direction


func accelerate_in_direction(direction: Vector2) -> void:
	var desired_velocity: Vector2 = direction * max_speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-acceleration * get_process_delta_time()))


func dash_in_direction(direction: Vector2, dash_force: float) -> void:
	var dash_velocity: Vector2 = direction * dash_force * max_speed
	velocity = dash_velocity
	decelerate()


func decelerate() -> void:
	accelerate_in_direction(Vector2.ZERO)


func move(character_body: CharacterBody2D) -> void:
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
