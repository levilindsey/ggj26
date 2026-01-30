class_name Player
extends Character


func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)


func _update_actions() -> void:
	super._update_actions()


func play_sound(sound_name: String) -> void:
	# FIXME: Implement sounds.
	match sound_name:
		"jump":
			pass
		"land":
			pass
