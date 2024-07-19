extends Node2D

var target_position: Vector2

@onready var shadow_sprite_2d: Sprite2D = $ShadowSprite2D


func _ready() -> void:
	global_position = target_position
