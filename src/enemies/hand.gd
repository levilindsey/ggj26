class_name Hand
extends Enemy


func _trigger_attack() -> void:
	pass


func play_animation(animation_name: String) -> void:
	# Add directional suffix.
	var suffix := "_right" if is_facing_right else "_left"
	var modified_name := "%s%s" % [animation_name, suffix]
	if animation_name == "attack":
		%AnimationPlayer.play(modified_name)
		animated_sprite.stop()
	else:
		super.play_animation(animation_name)
