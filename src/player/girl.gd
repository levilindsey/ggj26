class_name Girl
extends Player


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	%AttackDamageArea.monitoring = is_ability_active


func _trigger_ability() -> void:
	var animation_name := (
		"attack_right" if
		surface_state.is_facing_right else
		"attack_left"
	)
	%AnimationPlayer.play(animation_name)
