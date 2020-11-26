extends Node2D

export (int) var height

onready var main # assigned before adding

func _process(delta) -> void:
	move(delta)

func _destroyed() -> void:
	queue_free()

func move(delta) -> void:
	
	position.y -= main.fall_speed * delta
	if position.y + height < 0:
		_destroyed()
