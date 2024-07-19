extends CanvasLayer

@export var experience_manager: Node

@onready var experience_progress_bar: ProgressBar = %ExperienceProgressBar
@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var dash_progress_bar: ProgressBar = %DashProgressBar
@onready var total_damage_value: Label = %TotalDamageValue
@onready var total_eliminations_value: Label = %TotalEliminationsValue
@onready var experience_amount_label: Label = %ExperienceAmountLabel


func _ready() -> void:
	experience_progress_bar.value = 0
	health_progress_bar.value = 0
	dash_progress_bar.value = 1.0
	experience_amount_label.text = "00"
	experience_manager.experience_updated.connect(on_experience_updated)
	GameEvents.player_current_health_updated.connect(on_player_current_health_updated)
	GameEvents.player_dashed.connect(on_player_dashed)
	GameEvents.player_dash_cooldown.connect(on_player_dash_cooldown)

func set_eliminations_value(value: int) -> void:
	total_eliminations_value.text = "%d" % value


func set_damage_value(value: float) -> void:
	total_damage_value.text = "%0.1f" % value


func set_experience_value(value: int) -> void:
	experience_amount_label.text = "%02d" % value


func on_experience_updated(current_experience: float, target_experience: float) -> void:
	var percent = current_experience / target_experience
	experience_progress_bar.value = percent


func on_player_current_health_updated(current_health: float) -> void:
	health_progress_bar.value = current_health


func on_player_dash_cooldown(wait_time: float) -> void:
	var tween = create_tween()
	tween.tween_property(dash_progress_bar, "value", 1.0, wait_time)


func on_player_dashed(dash_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(dash_progress_bar, "value", 0.0, dash_duration)
	
