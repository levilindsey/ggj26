class_name IceSpike
extends Node2D


const _ICE_SPIKE_DAMAGE := 50
const _ICE_SPIKE_SPEED := 180.0
const _ICE_SPIKE_GROUNDED_DURATION_SEC := 4.0
const _SHATTER_DURATION_SEC := 5 * 1/12.0
const _ICE_SPIKE_FALL_DURATION_THRESHOLD_SEC := 4.0


var spawn_time_sec := -INF

var is_falling: bool:
	get:
		return not has_grounded

var grounded_start_time_sec := -INF
var has_grounded: bool:
	get:
		return grounded_start_time_sec >= 0

var shatter_start_time_sec := -INF
var has_shattered: bool:
	get:
		return shatter_start_time_sec >= 0
var shatter_end_time_sec: float:
	get:
		return (
			shatter_start_time_sec +
			_SHATTER_DURATION_SEC +
			ScaffolderTime.PHYSICS_TIME_STEP
		)

var frame_count := 0


func _ready() -> void:
	spawn_time_sec = G.time.get_play_time()


func _physics_process(delta: float) -> void:
	frame_count += 1
	var current_time := G.time.get_play_time()

	if (
		is_falling and
		(current_time - spawn_time_sec) >
			_ICE_SPIKE_FALL_DURATION_THRESHOLD_SEC
	):
		# The ice spike has been falling for too long.
		shatter()
	if not has_grounded and not has_shattered:
		# Keep falling.
		position.y += _ICE_SPIKE_SPEED * delta

		# Check for ground collision using RayCast2D
		if %GroundDetector.is_colliding():
			# Prevent spawning in walls.
			if frame_count <= 2:
				shatter()
			else:
				ground()
	elif not has_shattered:
		# Shatter after a delay on the ground.
		if (current_time >=
				grounded_start_time_sec + _ICE_SPIKE_GROUNDED_DURATION_SEC):
			shatter()
	elif current_time >= shatter_end_time_sec:
		# Clean-up after shattering is done.
		G.level.remove_ice_spike(self)


func ground() -> void:
	grounded_start_time_sec = G.time.get_play_time()
	%GroundDetector.enabled = false
	%DamageArea.monitoring = false
	# Enable the walking surface collision
	%WalkingSurface/CollisionShape2D.disabled = false


func shatter() -> void:
	shatter_start_time_sec = G.time.get_play_time()
	%AnimatedSprite2D.play("shatter")
	%DamageArea.monitoring = false
	# Disable the walking surface collision
	%WalkingSurface/CollisionShape2D.disabled = true


func _on_damage_area_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.take_damage(_ICE_SPIKE_DAMAGE)
	G.level.remove_ice_spike(self)
	shatter()
