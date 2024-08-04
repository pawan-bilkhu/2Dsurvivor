extends Node

@export var axe_ability_scene: PackedScene

@onready var timer: Timer = $Timer

var axe_quantity: int = 1
var base_damage: float = 0.0
var critical_chance: float = 0
var critical_damage: float = 0

var additional_damage_percent: float = 1
var additional_critical_chance: float = 0.0
var base_wait_time: float

var stats: WeaponStats

func _ready() -> void:
	stats = GameStats.get_weapon_stats_resource("axe")
	
	if stats != null:
		base_damage = stats.damage
		critical_chance = min(stats.critical_chance, 1.0)
		critical_damage = stats.critical_damage
		base_wait_time = max(stats.attack_interval, 0.05)
		
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	timer.start()


func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if not foreground_layer:
		return
	
	var separation_angle: float = TAU/axe_quantity
	var base_rotation: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
	
	for i in axe_quantity:
		var axe_ability_instance = axe_ability_scene.instantiate() as AxeAbility
		axe_ability_instance.base_rotation = base_rotation.rotated(i*separation_angle) 
		axe_ability_instance.died.connect(timer.start)
		foreground_layer.add_child(axe_ability_instance)
		axe_ability_instance.hitbox_component.damage = base_damage * additional_damage_percent
		axe_ability_instance.hitbox_component.critical_chance = min(critical_chance + additional_critical_chance, 1.0)
		axe_ability_instance.hitbox_component.critical_damage = critical_damage
		axe_ability_instance.global_position = player.marker_2d.global_position


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * 0.1)
	if upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * 0.05
		timer.wait_time =  max(base_wait_time * (1 - percent_reduction), 0.05)
