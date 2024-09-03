extends Node

@export var bomb_scene: PackedScene

@onready var timer: Timer = $Timer


var base_wait_time: float

var stats: WeaponStats


func _ready() -> void:
	stats = GameStats.get_weapon_stats_resource("bomb")
	
	if stats != null:
		base_wait_time = max(stats.attack_interval, 0.05)
		
	timer.wait_time = base_wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	timer.start()

func _on_timer_timeout() -> void:
	var foreground_layer: Node2D = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	
	var bomb_instance: Node2D = bomb_scene.instantiate()
	foreground_layer.add_child(bomb_instance)
	bomb_instance.launch_projectile(player.get_player_center_position(), player.get_aim_direction().normalized(), player.get_aim_direction().length(), PI/3)

func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	pass
