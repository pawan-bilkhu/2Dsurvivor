extends Node

signal experience_vial_collected(number: float)

func emit_experience_vial_collected(number: float) -> void:
	experience_vial_collected.emit(number)
