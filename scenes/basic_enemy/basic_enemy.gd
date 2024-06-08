extends CharacterBody2D

const MAX_SPEED: float = 75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()


func get_direction_to_player() -> Vector2:
	var player_node: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player_node:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO
		
