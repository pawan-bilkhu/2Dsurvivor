extends Node

@export var orbital_marker_scene: PackedScene = preload("res://scenes/ability/axe_ability_controller/orbital_marker_2d/orbital_marker.tscn")
@onready var orbital_layer: Node2D = $OrbitalLayer

var orbital_group: Array[Node2D] = []

var max_quantity: int = 10
var total_quantity: int = 1
var current_quantity: int = 0

var orbital_position: Array[int] = []

func _ready() -> void:
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	for i in max_quantity:
		orbital_position.append(i)
	
	generate_orbit()


func generate_orbit() -> void:
	var base_direction: Vector2
	var base_rotation_rate: float = PI
	var separation_angle: float = TAU/max_quantity
	
	if orbital_group.size() == 0:
		base_direction = Vector2.RIGHT
		create_orbital_markers(base_direction, base_rotation_rate, separation_angle)
		return

	create_orbital_markers(orbital_group[0].get_current_direction(), base_rotation_rate, separation_angle)


func create_orbital_markers(direction: Vector2, rotation_rate: float, separation_angle: float) -> void:
	while orbital_group.size() < total_quantity:
		var orbital_marker = orbital_marker_scene.instantiate()
		orbital_marker.set_current_direction(
			direction.rotated(
				orbital_position.pop_at(randi() % orbital_position.size()) * separation_angle
				)
			)
		orbital_marker.set_rotation_rate(rotation_rate)
		orbital_layer.add_child(orbital_marker)
		orbital_group.append(orbital_marker)
		current_quantity += 1


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_quantity":
		total_quantity = max(total_quantity + current_upgrades["axe_quantity"]["quantity"], max_quantity)
		generate_orbit()
