extends Node
class_name HealthComponent

signal died
signal health_changed
signal health_decreased

@export var max_health: float = 10
@export var current_health: float


func _ready() -> void:
	current_health = max_health


func damage(damage_amount: float) -> void:
	current_health = clamp(current_health - damage_amount, 0, max_health)
	health_changed.emit()
	if damage_amount > 0:
		health_decreased.emit()
	Callable(check_death).call_deferred()


func heal(health_amount: float) -> void:
	damage(-health_amount)


func set_max_health(health_amount: float ) -> void:
	max_health = health_amount
	current_health = max_health


func get_max_health() -> float:
	return max_health


func get_health_percent() -> float:
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)


func check_death() -> void:
	if current_health == 0:
		died.emit()
		owner.queue_free()
