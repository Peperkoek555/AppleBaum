extends Area2D

onready var main = get_parent()
onready var size : Vector2 # the size of the object

func _process(delta) -> void:
	move(delta)

func _destroyed() -> void:
	queue_free()

func move(delta) -> void:
	
	if position.y + size.y > 0:
		position.y -= main.fall_speed * delta
	else:
		_destroyed()
