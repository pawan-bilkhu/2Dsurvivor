extends CharacterBody2D

const ACCELERATION_SMOOTHING = 25
const MAX_SPEED: float = 150.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction_vector: Vector2 = get_movement_vector().normalized()
	var target_velocity = direction_vector*MAX_SPEED
	
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING)) 
	move_and_slide()


func get_movement_vector() -> Vector2:
	var direction_x: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var direction_y: float = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(direction_x, direction_y)
