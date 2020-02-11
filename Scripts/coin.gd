extends "res://Scripts/entity.gd"

var passed : bool # whether the coin passed the threshold to let in a new coin
var type : int # 0 = green candy; 1 = red candy

func _process(delta) -> void:
	
	if !passed && position.y < 130:
		
		passed = true
		get_parent().can_add_coin = true
