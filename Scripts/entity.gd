extends Area2D

onready var main = get_parent()

func _process(delta) -> void:
	
	if position.y > 0:
		position.y -= get_parent().speed_tree * delta
	else:
		queue_free()
		