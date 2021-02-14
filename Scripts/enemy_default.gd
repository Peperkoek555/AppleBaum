extends "res://Scripts/passing_object.gd"

func _destroyed() -> void:
	main._enemy_destroyed()
	._destroyed()

func rand_position(room_size : Vector2, no_rows : int) -> void:
	
	var row = g.random(no_rows - 1)
	var is_right = (row >= 2 + g.random(1))
	if is_right: scale.x *= -1 # mirror
	var width = room_size.x / no_rows
	 
	position = Vector2(width * (row + int(is_right)), room_size.y + height)
	for i in range(min(abs(row - 0), abs(row - (no_rows - 1)))):
		
		var NewBody = $Body.duplicate()
		NewBody.modulate = Color(1, 1, 1, 0.7)
		NewBody.play()
		NewBody.position = Vector2.LEFT * (width / 2) * (i + 1)
		NewBody.show()
		add_child(NewBody)
	
	$Head.frame = 0
	$Body.queue_free()
