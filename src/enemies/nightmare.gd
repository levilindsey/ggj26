class_name Nightmare
extends Enemy


@export var attack_damage := 50


func play_animation(animation_name: String) -> void:
	# Add directional suffix.
	var suffix := "_right" if is_facing_right else "_left"
	var modified_name := "%s%s" % [animation_name, suffix]
	if animation_name == "attack":
		%AnimationPlayer.play(modified_name)
		animated_sprite.stop()
	else:
		super.play_animation(animation_name)


func _trigger_attack() -> void:
	pass


func _on_attack_damage_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if current_behavior == Behavior.ATTACK:
		(body as Player).take_damage(attack_damage, self)
