extends Marker2D

@onready var timer: Timer = $Timer

var orbital_radius: float = 30.0
var rotation_rate: float:
	set = set_rotation_rate
var current_orbital_direction: Vector2:
	set = set_current_direction,
	get = get_current_direction

var axe_scene: PackedScene = preload("res://scenes/ability/axe_ability/axe_ability.tscn")
var axe_instance: Node2D = null

var base_damage: float = 0.0
var base_health: int = 1
var critical_chance: float = 0
var critical_damage: float = 0
var base_wait_time: float

var additional_damage_percent: float = 1
var additional_critical_chance: float = 0.0

var stats: WeaponStats


func _ready() -> void:
	stats = GameStats.get_weapon_stats_resource("axe")
	
	if stats != null:
		base_damage = stats.damage
		critical_chance = min(stats.critical_chance, 1.0)
		critical_damage = stats.critical_damage
		base_wait_time = max(stats.attack_interval, 0.05)
		
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	current_orbital_direction = current_orbital_direction.rotated(rotation_rate * delta)
	global_position = player.marker_2d.global_position + orbital_radius * current_orbital_direction
	
	if not axe_instance:
		return
	
	axe_instance.global_position = global_position


func create_axe() -> void:
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if not foreground_layer:
		return
	
	axe_instance = axe_scene.instantiate()
	axe_instance.tree_exited.connect(on_axe_destroyed)
	foreground_layer.add_child(axe_instance)
	axe_instance.health_component.set_max_health(base_health)
	axe_instance.hitbox_component.damage = base_damage * additional_damage_percent
	axe_instance.hitbox_component.critical_chance = min(critical_chance + additional_critical_chance, 1.0)
	axe_instance.hitbox_component.critical_damage = critical_damage


func on_axe_destroyed() -> void:
	timer.start()


func set_current_direction(orbital_direction: Vector2) -> void:
	current_orbital_direction = orbital_direction


func get_current_direction() -> Vector2:
	return current_orbital_direction

# set the rotation_rate in radians per frame
func set_rotation_rate(rate: float) -> void:
	rotation_rate = rate


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * 0.1)
	#if upgrade.id == "axe_rate":
		#var percent_reduction = current_upgrades["axe_rate"]["quantity"] * 0.05
		#timer.wait_time =  max(base_wait_time * (1 - percent_reduction), 0.05)


func _on_timer_timeout() -> void:
	create_axe()
