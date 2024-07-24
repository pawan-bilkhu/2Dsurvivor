extends CanvasLayer

@export var arena_time_manager: Node
@export var wave_manager: Node
@onready var time_label = %TimeLabel
@onready var current_wave_label: Label = %CurrentWaveLabel
@onready var wave_progress_bar: ProgressBar = %WaveProgressBar


func _ready() -> void:
	wave_manager.wave_updated.connect(on_wave_updated)
	wave_manager.remaining_enemies_updated.connect(on_remaining_enemies_updated)


func _process(delta: float) -> void:
	if !arena_time_manager:
		return
	var time_elapsed = arena_time_manager.get_time_elapsed()
	time_label.text = format_seconds_to_string(time_elapsed)


func format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds/60)
	var remaining_seconds = seconds - (minutes*60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))


func on_wave_updated(current_wave: int) -> void:
	current_wave_label.text = "Wave: %02d" % current_wave


func on_remaining_enemies_updated(remaining_enemies: int, total_enemies: int) -> void:
	#print("Arena Time UI")
	#print("Enemies remaining: %d, Total enemies: %d" % [remaining_enemies, total_enemies])
	
	var total: float = float(total_enemies)
	var remaining: float = float(remaining_enemies)
	wave_progress_bar.value = (total - remaining) / total
