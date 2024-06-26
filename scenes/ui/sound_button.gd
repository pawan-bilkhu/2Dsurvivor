extends Button

@onready var random_stream_player_component: AudioStreamPlayer = $RandomStreamPlayerComponent



func _on_pressed() -> void:
	random_stream_player_component.play_random()
