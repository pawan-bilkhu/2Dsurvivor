extends PanelContainer

signal selected

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hover_animation_player: AnimationPlayer = $HoverAnimationPlayer
@onready var texture_rect: TextureRect = %TextureRect

var disabled: bool = false

func play_in(delay: float = 0) -> void:
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	animation_player.play("in")


func play_discard() -> void:
	animation_player.play("discard")


func set_ability_upgrade(upgrade: AbilityUpgrade) -> void:
	name_label.text = upgrade.name
	texture_rect.texture = upgrade.icon
	description_label.text = upgrade.description


func select_card() -> void:
	disabled = true
	animation_player.play("selected")
	
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
		other_card.play_discard()
	
	await animation_player.animation_finished
	selected.emit()


func _on_gui_input(event: InputEvent) -> void:
	if disabled:
		return

	if event.is_action_pressed("left_click"):
		select_card()


func _on_mouse_entered() -> void:
	if disabled:
		return

	hover_animation_player.play("hover")
