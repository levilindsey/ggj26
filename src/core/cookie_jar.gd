class_name CookieJar
extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	%AnimatedSprite2D.play("nom")
	%AnimatedSprite2D.animation_finished.connect(_on_nommed)
	G.audio.play_player_sound("acquired_cookie")


func _on_nommed() -> void:
	if G.level.has_finished or not G.level.has_started:
		return
	G.audio.play_player_sound("game_win")
	G.level.win()
