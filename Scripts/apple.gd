extends Area2D

var hspd : float = 0
var sounds = [load("res://Sounds/game_over.wav"),
			  load("res://Sounds/coin.wav")]
var target_x : float
const T_blink : int = 5
var t_blink : int
var t_blink_period : int

onready var coinIcon = get_parent().get_node("GUI").get_node("Icon")
onready var main = get_parent()
onready var player = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	t_blink = T_blink

func _process(delta):
	
	#target_x = int(normal(get_global_mouse_position().x) / (main.room_width / 4.0)) * (main.room_width / 4.0) + main.room_width / 8.0
	target_x = normal(get_global_mouse_position().x)
	if position.x < target_x - 1 || position.x > target_x + 1:
		position.x += hspd * sign(target_x - position.x)
	else:
		hspd = 0
		
	move_acc()
	blink()

func blink() -> void:

	if t_blink_period > 0:
		t_blink_period -= 1
		
		if t_blink_period == 0:
			$Blinking.frame = abs($AnimatedSprite.frame - 1)
			$AnimatedSprite.hide()
			$Blinking.show()
		
	else:
		
		if t_blink > 0:
			t_blink -= 1
		else:
			t_blink = T_blink
			t_blink_period = 90 + g.random(45)
			$AnimatedSprite.frame = abs($Blinking.frame - 1)
			$Blinking.hide()
			$AnimatedSprite.show()

func move_acc() -> void:
	
	hspd = abs(target_x - position.x) / 10.0
	$AnimatedSprite.rotation_degrees = - sign(target_x - position.x) * abs(target_x - position.x) / 80 * 30

func normal(x : float) -> float:
	
	var x_new = x
	
	if x_new < 13:
		x_new = 13
	elif x_new > 147:
		x_new = 147
		
	return x_new

func collide(area):
	
	if !main.game_over:
		
		if area.is_in_group("coin"):
			
			if !area.eaten:
				player.stream = sounds[1]
				player.play()
				main.coins += g.coin_values[area.type]
				
				var prev_frame = coinIcon.frame
				coinIcon.animation = g.coin_types[area.type]
				coinIcon.frame = prev_frame + 1
				
				area.eaten = true
				
		elif area.is_in_group("enemy"):
			
			player.stream = sounds[0]
			player.play()
			main.end_game()
			hide()
