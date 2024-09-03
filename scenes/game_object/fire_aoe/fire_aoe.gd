extends Node2D

@onready var area_of_effect_component: AreaOfEffectComponent = $AreaOfEffectComponent
@onready var burn_sprite_2d: Sprite2D = %BurnSprite2D

var fire_stats: AOEStats = null : set = set_fire_stats

func _ready() -> void:
	GameEvents.game_paused.connect(set_burning_shader.bind(true))
	GameEvents.game_unpaused.connect(set_burning_shader.bind(false))
	
	set_fire_stats(GameStats.get_weapon_stats_resource("aoe_fire"))
	(burn_sprite_2d.material as ShaderMaterial).set_shader_parameter("base_intensity", 0.35)
	var tween: Tween = create_tween()
	tween.tween_property(burn_sprite_2d.material, "shader_parameter/base_intensity", 0.011, 1.0)
	
	
	var background_layer: Node2D = get_tree().get_first_node_in_group("background_layer")
	if not background_layer:
		return
		
	remove_child(burn_sprite_2d)
	background_layer.add_child(burn_sprite_2d)
	

func _process(delta: float) -> void:
	burn_sprite_2d.global_position = global_position


func set_fire_stats(stats: AOEStats) -> void:
	fire_stats = stats
	if fire_stats != null:
		area_of_effect_component.damage = fire_stats.damage
		area_of_effect_component.critical_chance = fire_stats.critical_chance
		area_of_effect_component.critical_damage = fire_stats.critical_damage
		area_of_effect_component.set_interval(fire_stats.attack_interval)
		area_of_effect_component.set_duration(fire_stats.damage_duration)
	
	area_of_effect_component.start_attack()


func destroy() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(burn_sprite_2d.material, "shader_parameter/base_intensity", 0.35, 1.0)
	await tween.finished
	burn_sprite_2d.queue_free()
	queue_free()


func set_burning_shader(value: bool) -> void:
	(burn_sprite_2d.material as ShaderMaterial).set_shader_parameter("is_paused", value)
