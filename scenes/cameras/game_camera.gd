extends Camera2D

var target_position: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	aquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 10))


func aquire_target() -> void:
	var player_nodes: Array = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player: CharacterBody2D = player_nodes[0] as CharacterBody2D
		target_position = player.global_position
