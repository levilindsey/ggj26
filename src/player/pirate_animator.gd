@tool
class_name PirateAnimator
extends CharacterAnimator


func play(animation_name: String) -> void:
	# Handle melee animation logic (from parent class)
	if is_melee:
		if animation_name == "attack":
			return
		else:
			player.stop_melee_animation()

	# Add directional suffix
	var suffix := "_right" if _is_facing_right else "_left"
	animated_sprite.play("%s%s" % [animation_name, suffix])
