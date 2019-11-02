extends Area2D

var hspd : float = 0
var target_x : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	target_x = normal(get_global_mouse_position().x)
	if position.x < target_x - 1 || position.x > target_x + 1:
		position.x += hspd * sign(target_x - position.x)
	else:
		hspd = 0
		
	move_acc()

func move_acc() -> void:
	
	hspd = abs(target_x - position.x) / 30
	$Sprite.rotation_degrees = - sign(target_x - position.x) * abs(target_x - position.x) / 80 * 30

func normal(x : float) -> float:
	
	var x_new = x
	
	if x_new < 6:
		x_new = 6
	elif x_new > 74:
		x_new = 74
		
	return x_new
