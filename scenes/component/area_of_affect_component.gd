extends HitboxComponent
class_name AreaOfEffectComponent


var damage_duration: float
var damage_interval: float

@onready var damage_interval_timer: Timer = $DamageIntervalTimer
@onready var damage_duration_timer: Timer = $DamageDurationTimer

var colliding_areas: Array[Area2D] = []

func start_attack() -> void:
	damage_interval_timer.start(damage_interval)
	damage_duration_timer.start(damage_duration)
	print(self)
	

func _on_area_entered(area: Area2D) -> void:
	if not area is HurtboxComponent:
		return
	
	colliding_areas.append(area)


func _on_area_exited(area: Area2D) -> void:
	if not area is HurtboxComponent:
		return
	
	colliding_areas.erase(area)


func _on_damage_duration_timer_timeout() -> void:
	owner.destroy()


func _on_damage_interval_timer_timeout() -> void:
	for area in colliding_areas:
		area._on_area_entered(self)


func set_duration(duration: float) -> void:
	damage_duration = duration


func set_interval(interval: float) -> void:
	damage_interval = interval
