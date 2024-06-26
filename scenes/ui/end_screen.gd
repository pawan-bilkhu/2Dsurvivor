extends CanvasLayer

@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var panel_container: PanelContainer = %PanelContainer


func _ready() -> void:
	restart_button.pressed.connect(on_restart_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	panel_container.pivot_offset = panel_container.size / 2
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true


func set_defeat() -> void:
	title_label.text = "Defeat"
	description_label.text = "You lost!"


func on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_quit_button_pressed() -> void:
	get_tree().quit()


