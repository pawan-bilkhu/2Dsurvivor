extends CanvasLayer

signal transition_halfway

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var skip_emit: bool


func transition() -> void:
	skip_emit = false
	animation_player.play("default")
	await transition_halfway
	skip_emit = true
	animation_player.play_backwards("default")


func emit_transitioned_halfway() -> void:
	if skip_emit:
		skip_emit = false
		return
	transition_halfway.emit()
