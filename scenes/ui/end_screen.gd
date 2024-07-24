extends CanvasLayer

@onready var continue_button: Button = %ContinueButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var panel_container: PanelContainer = %PanelContainer
@onready var victory_stream_player: AudioStreamPlayer = $VictoryStreamPlayer
@onready var defeat_stream_player: AudioStreamPlayer = $DefeatStreamPlayer
@onready var time_label: Label = %TimeLabel
@onready var time_value: Label = %TimeValue
@onready var damage_label: Label = %DamageLabel
@onready var damage_value: Label = %DamageValue
@onready var eliminations_label: Label = %EliminationsLabel
@onready var eliminations_value: Label = %EliminationsValue
@onready var margin_container: MarginContainer = $MarginContainer
@onready var stats_panel_container: PanelContainer = %StatsPanelContainer


var defeat: bool = false

func _ready() -> void:
	
	continue_button.pressed.connect(on_continue_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	margin_container.pivot_offset = margin_container.size / 2
	stats_panel_container.pivot_offset = stats_panel_container.size / 2
	
	continue_button.disabled = true
	quit_button.disabled = true
	
	var tween = create_tween()
	tween.tween_property(margin_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(stats_panel_container, "scale", Vector2.ZERO, 0)

	tween.tween_property(margin_container, "scale", Vector2.ONE, 0.8)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	
	tween.tween_callback(play_jingle)


func set_defeat() -> void:
	title_label.text = "Defeat"
	description_label.text = "You lost!"
	defeat = true


func play_jingle() -> void:
	if defeat:
		defeat_stream_player.play()
	else:
		victory_stream_player.play()
	
	var tween = create_tween()
	tween.tween_property(stats_panel_container, "scale", Vector2.ONE, 1.0)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	
	continue_button.disabled = false
	quit_button.disabled = false
	
	

func on_continue_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/meta_menu.tscn")


func on_quit_button_pressed() -> void:
	ScreenTransition.transition_to_scene("res://scenes/ui/main_menu.tscn")
	await ScreenTransition.transition_halfway


func set_stats(time: float, damage: float, elimination: int) -> void:
	time_value.text = format_seconds_to_string(time)
	damage_value.text = "%0.1f HP" % damage
	eliminations_value.text = "%d" %elimination
	

func format_seconds_to_string(seconds: float) -> String:
	var minutes = floor(seconds/60)
	var remaining_seconds = seconds - (minutes*60)
	return str(minutes) + ":" + ("%02d" % floor(remaining_seconds))
