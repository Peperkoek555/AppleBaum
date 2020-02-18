extends Area2D

onready var main = get_parent()
onready var size : Vector2 # the physical size of the entity

func _process(delta) -> void:
	
	if position.y + size.y / 2 > 0:
		position.y -= get_parent().speed_tree * delta
	else:
		destroy()

func destroy() -> void:
	queue_free()