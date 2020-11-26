extends "res://Scripts/passing_object.gd"

func _destroyed() -> void:
	main._enemy_destroyed()
	._destroyed()
