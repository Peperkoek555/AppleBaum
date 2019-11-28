extends Area2D

var hspd : float = 0
var sounds = [load("res://Sounds/game_over.wav"),
			  load("res://Sounds/coin.wav")]
var target_x : float

onready var main = get_parent()
onready var player = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	#target_x = int(normal(get_global_mouse_position().x) / (main.room_width / 4.0)) * (main.room_width / 4.0) + main.room_width / 8.0
	target_x = normal(get_global_mouse_position().x)
	if position.x < target_x - 1 || position.x > target_x + 1:
		position.x += hspd * sign(target_x - position.x)
	else:
		hspd = 0
		
	move_acc()

func move_acc() -> void:
	
	hspd = abs(target_x - position.x) / 10.0
	$Sprite.rotation_degrees = - sign(target_x - position.x) * abs(target_x - position.x) / 80 * 30

func normal(x : float) -> float:
	
	var x_new = x
	
	if x_new < 6:
		x_new = 6
	elif x_new > 74:
		x_new = 74
		
	return x_new

func collide(area):
	
	if !main.game_over:
		
		if area.is_in_group("coin"):
			
			player.stream = sounds[1]
			player.play()
			main.score += 1
			area.queue_free()
				
		elif area.is_in_group("enemy"):
			
			player.stream = sounds[0]
			player.play()
			main.end_game()
			hide()
