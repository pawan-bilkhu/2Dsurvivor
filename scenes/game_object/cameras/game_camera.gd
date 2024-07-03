extends Camera2D

var target_position: Vector2 = Vector2.ZERO
@export var random_strength: float = 50.0
@export var shake_fade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var shake_range: float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.hammer_smash.connect(on_hammer_smash)
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	aquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		
		offset = random_offset()


func apply_shake(hammer_global_position: Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not player:
		return
	var distance_to_player: float = hammer_global_position.distance_squared_to(player.global_position)
	shake_strength = (pow(shake_range, 2) / max(1, distance_to_player)) * random_strength


func aquire_target() -> void:
	var player_nodes: Array = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player: CharacterBody2D = player_nodes[0] as CharacterBody2D
		target_position = player.global_position


func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))


func on_hammer_smash(hammer_global_position: Vector2) -> void:
	apply_shake(hammer_global_position)
