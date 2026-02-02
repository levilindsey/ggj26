class_name Chicken
extends Player


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)


func _trigger_ability() -> void:
	# TODO: LEVI: Implement abilities.
	pass
	G.warning("WOAH! That ability was so cool!")


func take_damage(damage: int, enemy: Enemy) -> void:
	G.print("Chicken is ignoring damage: %d" % damage)
