class_name Hand
extends Enemy


func _trigger_attack() -> void:
	pass


func play_animation(animation_name: String) -> void:
	# FIXME: Implement hand animations and behaviors.
	animated_sprite.play(animation_name)
