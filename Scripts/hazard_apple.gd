extends "res://Scripts/entity.gd"

# @override
func move(delta) -> void:
	
	if position.y - size.y / 2 < main.room_height:
		position.y += main.speed_tree * delta
	else:
		destroy()

func destroy() -> void:
	main.hazard_free = true
	.destroy()
