extends CanvasLayer

@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel


func _ready() -> void:
	get_tree().paused = true


func set_defeat() -> void:
	title_label.text = "Defeat"
	description_label.text = "You lost!"


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
