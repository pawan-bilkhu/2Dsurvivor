extends CanvasLayer

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

var options_scene: PackedScene = preload("res://scenes/ui/options_menu.tscn")

func _ready() -> void:
	play_button.pressed.connect(on_play_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)


func on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func on_options_pressed() -> void:
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_options_closed.bind(options_instance))


func on_quit_pressed() -> void:
	get_tree().quit()


func on_options_closed(options_instance: Node) -> void:
	options_instance.queue_free()
