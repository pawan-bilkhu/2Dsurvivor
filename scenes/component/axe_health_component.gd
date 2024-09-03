extends HealthComponent


func check_death() -> void:
	if current_health == 0:
		died.emit()
