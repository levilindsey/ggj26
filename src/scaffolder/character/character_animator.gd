class_name CharacterAnimator
extends Node2D


@export var faces_right_by_default := true
@export var animated_sprite: AnimatedSprite2D = null

var _is_facing_right := true


func face_left() -> void:
	_is_facing_right = false
	animated_sprite.flip_h = faces_right_by_default


func face_right() -> void:
	_is_facing_right = true
	animated_sprite.flip_h = not faces_right_by_default


func play(animation_name: String) -> void:
	animated_sprite.play(animation_name)
