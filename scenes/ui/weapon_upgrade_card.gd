extends PanelContainer


@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel

@onready var damage_value: Label = %DamageValue
@onready var damage_buff: Label = %DamageBuff
@onready var damage_cost: Label = %DamageCost
@onready var damage_button: Button = %DamageButton
@onready var damage_upgrade_count_label: Label = %DamageUpgradeCountLabel

@onready var critical_chance_value: Label = %CriticalChanceValue
@onready var critical_chance_buff: Label = %CriticalChanceBuff
@onready var critical_chance_cost: Label = %CriticalChanceCost
@onready var crit_chance_button: Button = %CritChanceButton
@onready var critical_chance_upgrade_count_label: Label = %CriticalChanceUpgradeCountLabel

@onready var critical_damage_value: Label = %CriticalDamageValue
@onready var critical_damage_buff: Label = %CriticalDamageBuff
@onready var critical_damage_cost: Label = %CriticalDamageCost
@onready var crit_damage_button: Button = %CritDamageButton
@onready var critical_damage_upgrade_count_label: Label = %CriticalDamageUpgradeCountLabel

@onready var attack_interval_value: Label = %AttackIntervalValue
@onready var attack_interval_buff: Label = %AttackIntervalBuff
@onready var attack_interval_cost: Label = %AttackIntervalCost
@onready var attack_invterval_button: Button = %AttackInvtervalButton
@onready var attack_inverval_upgrade_count_label: Label = %AttackInvervalUpgradeCountLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var upgrade: WeaponUpgrade
var stats: Dictionary = {}


func _ready() -> void:
	pivot_offset = size / 2
	damage_button.pressed.connect(on_damage_button_pressed)
	crit_chance_button.pressed.connect(on_critical_chance_button_pressed)
	crit_damage_button.pressed.connect(on_cirtical_damage_button_pressed)
	attack_invterval_button.pressed.connect(on_attack_interval_button_pressed)


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
	
	damage_value.text = "%0.1f HP" % stats["damage"]["magnitude"]
	damage_buff.text = "+%0.1f HP" % upgrade.damage_increase
	damage_cost.text = "x%d" % upgrade.damage_cost
	damage_upgrade_count_label.text = "x%d" % stats["damage"]["current_upgrade_quantity"]
	
	critical_chance_value.text = "%0.1f %%" % (min(stats["critical_chance"]["magnitude"], 1.0) * 100)
	critical_chance_buff.text = "+%0.1f %%" % (upgrade.critcal_chance_increase * 100)
	critical_chance_cost.text = "x%d" % upgrade.critical_chance_cost
	critical_chance_upgrade_count_label.text = "x%d" % stats["critical_chance"]["current_upgrade_quantity"]
	
	critical_damage_value.text = "%0.1f %%" % (stats["critical_damage"]["magnitude"] * 100)
	critical_damage_buff.text = "+%0.1f %%" % (upgrade.critcal_damage_increase * 100)
	critical_damage_cost.text = "x%d" % upgrade.critical_damage_cost
	critical_damage_upgrade_count_label.text = "x%d" % stats["critical_damage"]["current_upgrade_quantity"]
	
	attack_interval_value.text = "%0.1f s" % stats["attack_interval"]["magnitude"]
	attack_interval_buff.text = "-%0.1f s" % upgrade.attack_interval_decrease
	attack_interval_cost.text = "x%d" % upgrade.attack_interval_cost
	attack_inverval_upgrade_count_label.text = "x%d" % stats["attack_interval"]["current_upgrade_quantity"]


func update_progress() -> void:
	is_button_disabled(damage_button, "damage", upgrade.damage_cost, upgrade.damage_max_quantity)
	is_button_disabled(crit_chance_button, "critical_chance", upgrade.critical_chance_cost, upgrade.critical_chance_max_quantity)
	is_button_disabled(crit_damage_button, "critical_damage", upgrade.critical_damage_cost, upgrade.critical_damage_max_quantity)
	is_button_disabled(attack_invterval_button, "attack_interval", upgrade.attack_interval_cost, upgrade.attack_interval_max_quantity)


func is_button_disabled(button: Button, stat_id: String, upgrade_cost: float, upgrade_max_quantity: int) -> void:
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var current_quantity = stats[stat_id]["current_upgrade_quantity"]
	var is_maxed = current_quantity >= upgrade_max_quantity
	if upgrade_max_quantity == 0:
		is_maxed = false
	button.disabled = currency < upgrade_cost || is_maxed
	if is_maxed:
		button.text = "Maxed"


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


func on_damage_button_pressed() -> void:
	if not upgrade:
		return
	
	GameStats.add_weapon_stat(upgrade.id, "damage", upgrade.damage_increase)
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	
	set_upgrade_card(self.upgrade, stats)
	
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.damage_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
	GameEvents.emit_meta_upgrade_purchased()


func on_critical_chance_button_pressed() -> void:
	if not upgrade:
		return
	
	GameStats.add_weapon_stat(upgrade.id, "critical_chance", upgrade.critcal_chance_increase)
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	
	set_upgrade_card(self.upgrade, stats)
	
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.critical_chance_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
	GameEvents.emit_meta_upgrade_purchased()


func on_cirtical_damage_button_pressed() -> void:
	if not upgrade:
		return
	
	GameStats.add_weapon_stat(upgrade.id, "critical_damage", upgrade.critcal_damage_increase)
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	
	set_upgrade_card(self.upgrade, stats)
	
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.critical_damage_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
	GameEvents.emit_meta_upgrade_purchased()




func on_attack_interval_button_pressed() -> void:
	if not upgrade:
		return
	
	GameStats.add_weapon_stat(upgrade.id, "attack_interval", -upgrade.attack_interval_decrease)
	stats = GameStats.get_weapon_stats(self.upgrade.id)
	
	set_upgrade_card(self.upgrade, stats)
	
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade.attack_interval_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	animation_player.play("selected")
	GameEvents.emit_meta_upgrade_purchased()
