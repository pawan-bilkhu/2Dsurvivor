extends AudioStreamPlayer

@onready var timer: Timer = $Timer


func _on_finished() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	play()
