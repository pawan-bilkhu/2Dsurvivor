extends Node

@export var time: float = 0.0

func _ready() -> void:
	time = 0.0

func _process(delta: float) -> void:
	time += delta


func get_time_elapsed() -> float:
	return time
