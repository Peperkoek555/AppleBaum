extends "res://Scripts/passing_object.gd"

func _created(area : String, room_size : Vector2, no_rows : int) -> void:
	
	$Head.animation = area
	
	var row = g.random(no_rows - 1)
	var is_right = (row >= 2 + g.random(1))
	var width = room_size.x / no_rows
	
	match area:
		
		"forest":
			_created_head(is_right, room_size, width, height, row)
			_created_body(no_rows, row, width)
		"winter":
			_created_head(false, room_size, width, height, row)
		"jungle":
			_created_head(false, room_size, width, height, row)
	
	$Head.frame = 0
	$BodyTmp.queue_free() 

func _created_head(is_mirrored : bool, room_size : Vector2, width : int, \
	height : int, row : int) -> void:
	
	if is_mirrored: scale.x *= -1
	position = Vector2(width * (row + int(is_mirrored)), room_size.y + height)

func _created_body(no_rows : int, row : int, width : int) -> void:
	
	for i in range(min(abs(row - 0), abs(row - (no_rows - 1)))):
		
		var NewBody = $BodyTmp.duplicate()
		NewBody.play()
		NewBody.position = Vector2.LEFT * (width / 2) * (i + 1)
		NewBody.show()
		add_child(NewBody)

func _destroyed() -> void:
	main._enemy_destroyed()
	._destroyed()
