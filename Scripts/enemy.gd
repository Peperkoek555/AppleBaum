extends "res://Scripts/entity.gd"

func _process(delta) -> void:
	
	move_eyes()

func move_eyes() -> void:
	
	$Eye0.rotation = get_parent().get_node("Apple").position.angle()
	$Eye1.rotation = get_parent().get_node("Apple").position.angle()