extends Area2D

var hspd : float = 0
var sounds_game = [load("res://Sounds/game_over.wav")]
var target_x : float
const T_blink : int = 5
var t_blink : int
var t_blink_period : int

onready var coinIcon = get_parent().get_node("GUI").get_node("CoinIcon")
onready var main = get_parent()

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
				
				if area.type == 3:
					$PlayerAcornDiamond.play()
				else:
					
					if area.queue_id == main.coin_queue_last:
						main.coin_pitch += 1 / 12.0
					else:
						main.coin_pitch = 1.0
						main.coin_queue_last = area.queue_id
						
					$PlayerAcorn.pitch_scale = main.coin_pitch
					$PlayerAcorn.play()
				
				main.coins += g.coin_values[area.type]
				coinIcon.animation = g.coin_types[area.type]
				
				area.eaten = true
				
		elif area.is_in_group("enemy"):
			
			$PlayerGeneral.stream = sounds_game[0]
			$PlayerGeneral.play()
			main.end_game()
			hide()
