extends Area2D

var hspd : float = 0
var t_blink : Object
var target_x : float

const TIMER = preload("res://Scripts/timer.gd")
onready var image = $AnimatedSprite
onready var main = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	t_blink = TIMER.new()
	t_blink.init(3, 1)

func _process(delta):
	
	follow_mouse()
	match t_blink.advance_perc(delta, [0.97, 1.0]):
		
		0:
			var frame = image.frame
			image.play("blinking")
			image.frame = frame
		1:
			var frame = image.frame
			image.play("idle")
			image.frame = frame

func collide(area):
	
	if !main.game_over:
		
		if area.is_in_group("acorns"):
			if !area.is_eaten:
				main.collect_acorn(area.queue_id, area.type)
				area.is_eaten = true
				
		elif area.is_in_group("enemies"):
			
			$Player.play()
			main.game_end()
			hide()

func follow_mouse() -> void:
	
	target_x = normal(get_global_mouse_position().x)
	if position.x < target_x - 1 || position.x > target_x + 1:
		position.x += hspd * sign(target_x - position.x)
	else:
		hspd = 0
	
	hspd = abs(target_x - position.x) / 10.0
	image.rotation_degrees = -sign(target_x - position.x) * \
		abs(target_x - position.x) / 80 * 30

func normal(x : float) -> float:
	
	var x_new = x
	
	if x_new < 13:
		x_new = 13
	elif x_new > 147:
		x_new = 147
		
	return x_new
