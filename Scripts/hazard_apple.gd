extends "res://Scripts/entity.gd"

# @override
func move(delta) -> void:
	
	if position.y - size.y / 2 > main.room_height:
		position.y += main.speed_tree * delta * 2
	else:
		destroy()
