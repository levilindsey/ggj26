class_name Dinosaur
extends Player


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	%AttackDamageArea.monitoring = is_ability_active


func _trigger_ability() -> void:
	play_melee_animation()
