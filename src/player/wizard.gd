class_name Wizard
extends Player


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)


func _trigger_ability() -> void:
	G.print("ICE SPIKE!")

	var ice_spike_offset: Vector2 = %IceSpikeSpawnPositionRight.position
	if not surface_state.is_facing_right:
		ice_spike_offset.x *= -1

	G.level.add_ice_spike(global_position + ice_spike_offset)
