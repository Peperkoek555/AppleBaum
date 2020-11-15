extends "res://Scripts/passing_object.gd"

func _ready():
	size = Vector2.ONE * 32

func _destroyed() -> void:
	main._enemy_destroyed()
	._destroyed()
