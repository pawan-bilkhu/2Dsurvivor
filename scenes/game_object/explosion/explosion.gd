extends Node2D

@onready var smoke: GPUParticles2D = $Smoke
@onready var fire: GPUParticles2D = $Fire
@onready var flash: GPUParticles2D = $Flash
@onready var sparks: GPUParticles2D = $Sparks
@onready var shadow_sprite_2d: Sprite2D = $ShadowSprite2D


@onready var hitbox_component: HitboxComponent = $HitboxComponent


var additional_damage_percent: float = 1
var additional_critical_chance: float = 0.0

var explosion_stats: WeaponStats: set = set_explosion_stats

func _ready() -> void:
	set_explosion_stats(GameStats.get_weapon_stats_resource("bomb"))
	
	var background_layer: Node2D = get_tree().get_first_node_in_group("background_layer")
	
	if not background_layer:
		return
	
	remove_child(shadow_sprite_2d)
	background_layer.add_child(shadow_sprite_2d)
	
	
	emit_particles(true)


func set_explosion_stats(stats: WeaponStats) -> void:
	explosion_stats = stats
	if explosion_stats != null:
			hitbox_component.damage = explosion_stats.damage + additional_damage_percent
			hitbox_component.critical_chance = min(explosion_stats.critical_chance + additional_critical_chance, 1.0)
			hitbox_component.critical_damage = explosion_stats.critical_damage + additional_damage_percent


func emit_particles(emitting: bool) -> void:
	shadow_sprite_2d.global_position = global_position
	var tween: Tween = create_tween()
	tween.tween_property(shadow_sprite_2d, "modulate:a", 0.8, 0.0)
	smoke.emitting = emitting
	fire.emitting = emitting
	flash.emitting = emitting
	sparks.emitting = emitting
	
	
	tween.tween_property(shadow_sprite_2d, "modulate:a", 0.0, 0.5)
	
	fire.finished.connect(queue_free)
