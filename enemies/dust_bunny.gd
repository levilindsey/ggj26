class_name DustBunny
extends Enemy


## Only relevant if bounces_when_attacking is true.
@export var attack_bounce_boost := 80.0


func _trigger_attack() -> void:
	G.fatal("Abstract Enemy._trigger_attack not implemented.")

	# FIXME: Implement attacks.
	#attack_bounce_boost
