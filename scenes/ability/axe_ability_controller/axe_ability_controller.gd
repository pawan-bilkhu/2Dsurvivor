extends Node

@export var axe_ability_scene: PackedScene
@onready var timer: Timer = $Timer

var base_damage: float = 10
var additional_damage_percent: float = 1
var base_wait_time: float


func _ready() -> void:
	base_wait_time = timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

func _on_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if not foreground_layer:
		return
	
	var axe_ability_instance = axe_ability_scene.instantiate() as Node2D
	foreground_layer.add_child(axe_ability_instance)
	axe_ability_instance.global_position = player.global_position
	axe_ability_instance.hitbox_component.damage = base_damage * additional_damage_percent

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if upgrade.id == "axe_damage":
		additional_damage_percent = 1 + (current_upgrades["axe_damage"]["quantity"] * 0.1)
	if upgrade.id == "axe_rate":
		var percent_reduction = current_upgrades["axe_rate"]["quantity"] * 0.05
		timer.wait_time = base_wait_time * (1 - percent_reduction)
