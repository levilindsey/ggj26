class_name PirateAnimator
extends CharacterAnimator


func play(animation_name: String) -> void:
	var suffix := "_right" if _is_facing_right else "_left"
	animated_sprite.play("%s%s" % [animation_name, suffix])
