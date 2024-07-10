extends Resource
class_name WeaponUpgrade

@export var id: String
@export var title: String
@export var icon: Texture2D
@export var max_quantity: int = 1
@export var experience_cost: int = 10
@export var damage_increase: float = 5
@export var critcal_chance_increase: float = 0.05
@export var critcal_damage_increase: float = 0.05
@export var attack_interval_decrease: float = 0.5
