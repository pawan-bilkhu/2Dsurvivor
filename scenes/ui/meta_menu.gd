extends CanvasLayer


@onready var grid_container: GridContainer = %MetaGridContainer
@onready var back_button: Button = %BackButton

@export var meta_upgrades: Array[MetaUpgrade] = []
@export var weapon_upgrades: Array[WeaponUpgrade] = []
var meta_upgrade_card_scene: PackedScene = preload("res://scenes/ui/meta_upgrade_card.tscn")
var weapon_meta_upgrade_card_scene: PackedScene = preload("res://scenes/ui/weapon_upgrade_card.tscn")

func _ready() -> void:
	back_button.pressed.connect(on_back_pressed)
	
	for child in grid_container.get_children():
		child.queue_free()
	
	for upgrade in meta_upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)
	
	for upgrade in weapon_upgrades:
		var weapon_meta_upgrade_card_instance = weapon_meta_upgrade_card_scene.instantiate()
		grid_container.add_child(weapon_meta_upgrade_card_instance)
		weapon_meta_upgrade_card_instance.set_meta_upgrade(upgrade)



func on_back_pressed() -> void:
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
