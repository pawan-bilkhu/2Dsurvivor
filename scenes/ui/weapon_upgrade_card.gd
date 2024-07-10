extends PanelContainer


@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var damage_value: Label = %DamageValue
@onready var damage_buff: Label = %DamageBuff
@onready var critical_chance_value: Label = %CriticalChanceValue
@onready var critical_chance_buff: Label = %CriticalChanceBuff
@onready var critical_chance_damage_value: Label = %CriticalChanceDamageValue
@onready var critical_chance_damage_buff: Label = %CriticalChanceDamageBuff
@onready var attack_interval_value: Label = %AttackIntervalValue
@onready var attack_interval_buff: Label = %AttackIntervalBuff
@onready var progress_label: Label = %ProgressLabel
@onready var count_label: Label = %CountLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var upgrade: WeaponUpgrade
var stats: Dictionary = {}


func _ready() -> void:
	purchase_button.pressed.connect(on_purchase_pressed)
	pivot_offset = size / 2


func set_meta_upgrade(upgrade: WeaponUpgrade) -> void:
	self.upgrade = upgrade
	name_label.text = upgrade.title
	
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	if stats.is_empty():
		return
	
	set_upgrade_card(upgrade, stats)
	
	update_progress()


func set_upgrade_card(upgrade: WeaponUpgrade, stats: Dictionary) -> void:
	icon.texture = upgrade.icon
	
	damage_value.text = "%0.1f HP" % stats["base_damage"]
	damage_buff.text = "+%0.1f HP" % upgrade.damage_increase
	
	critical_chance_value.text = "%0.1f %%" % (stats["critical_chance"] * 100)
	critical_chance_buff.text = "+%0.1f %%" % (upgrade.critcal_chance_increase * 100)
	
	critical_chance_damage_value.text = "%0.1f %%" % (stats["critical_damage"] * 100)
	critical_chance_damage_buff.text = "+%0.1f %%" % (upgrade.critcal_damage_increase * 100)
	
	attack_interval_value.text = "%0.1f s" % stats["attack_interval"]
	attack_interval_buff.text = "-%0.1f s" % upgrade.attack_interval_decrease


func update_progress() -> void:
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var current_quantity = stats["upgrade_quantity"]
	
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


func on_purchase_pressed() -> void:
	if not upgrade:
		return
	
	GameStats.update_weapon_stats(upgrade)
	
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	
	set_upgrade_card(self.upgrade, stats)
	
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.experience_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
