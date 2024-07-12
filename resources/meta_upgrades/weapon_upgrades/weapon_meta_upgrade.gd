extends Resource
class_name WeaponUpgrade

@export var id: String
@export var title: String
@export var icon: Texture2D
 
@export var damage_increase: float = 5
@export var damage_cost: float = 500.0
@export var damage_max_quantity: int = 10

@export var critcal_chance_increase: float = 0.05
@export var critical_chance_cost: float = 500.0
@export var critical_chance_max_quantity: int = 5

@export var critcal_damage_increase: float = 0.05
@export var critical_damage_cost: float = 500.0
@export var critical_damage_max_quantity: int = 5

@export var attack_interval_decrease: float = 0.5
@export var attack_interval_cost: float = 500.0
@export var attack_interval_max_quantity: int = 10
