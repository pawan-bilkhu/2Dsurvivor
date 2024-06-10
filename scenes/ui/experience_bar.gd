extends CanvasLayer

@export var experience_manager: Node
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar

func _ready() -> void:
	progress_bar.value = 0
	experience_manager.experience_updated.connect(on_experience_updated)

func on_experience_updated(current_experience: float, target_experience: float) -> void:
	var percent = current_experience / target_experience
	progress_bar.value = percent
