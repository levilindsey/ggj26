@tool
class_name CharacterAnimator
extends Node2D


@export var faces_right_by_default := true
@export var animated_sprite: AnimatedSprite2D = null

@export var frame := 0:
	set(value):
		frame = value
		animated_sprite.frame = frame

@export var animation := "":
	set(value):
		animation = value
		animated_sprite.animation = animation

@export var editor_only_flip_h := false:
	set(value):
		editor_only_flip_h = value
		animated_sprite.flip_h = value

var _is_facing_right := true

var initial_animated_sprite_position := Vector2.INF


func _ready() -> void:
	initial_animated_sprite_position = animated_sprite.position


func face_left() -> void:
	_is_facing_right = false
	animated_sprite.flip_h = faces_right_by_default
	if animated_sprite.flip_h:
		animated_sprite.position.x = -initial_animated_sprite_position.x
	else:
		animated_sprite.position.x = initial_animated_sprite_position.x


func face_right() -> void:
	_is_facing_right = true
	animated_sprite.flip_h = not faces_right_by_default
	if animated_sprite.flip_h:
		animated_sprite.position.x = -initial_animated_sprite_position.x
	else:
		animated_sprite.position.x = initial_animated_sprite_position.x


func play(animation_name: String) -> void:
	animated_sprite.play(animation_name)
