extends PanelContainer


@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label: Label = %ProgressLabel
@onready var count_label: Label = %CountLabel



var upgrade: MetaUpgrade

func _ready() -> void:
	purchase_button.pressed.connect(on_purchase_pressed)
	pivot_offset = size/2


func set_meta_upgrade(upgrade: MetaUpgrade) -> void:
	self.upgrade = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()


func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var current_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has(upgrade.id):
		current_quantity = MetaProgression.save_data["meta_upgrades"][upgrade.id]["quantity"]
	var is_maxed = current_quantity >= upgrade.max_quantity
	var percent = currency / upgrade.experience_cost
	percent = min(percent, 1)
	# progress_bar.value = lerpf(progress_bar.value, percent, 0.5)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1 || is_maxed
	
	if is_maxed:
		purchase_button.text = "Max"
	
	progress_label.text = str(currency) + "/" + str(upgrade.experience_cost)
	count_label.text = "x%d" % current_quantity


func select_card() -> void:
	animation_player.play("selected")


func on_purchase_pressed() -> void:
	if not upgrade:
		return
	
	MetaProgression.add_meta_upgrade(upgrade)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.experience_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
