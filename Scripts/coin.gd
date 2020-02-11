extends "res://Scripts/entity.gd"

var eaten : bool
var passed : bool # whether the coin passed the threshold to let in a new coin
var type : int = 0 # 0 = normal; 1 = silver; 2 = gold: 3 = diamond
var t_death : float = 10

func _ready():
	
	if get_parent().score >= 20:
		if g.random(3) == 0:
			type += 1
			$AnimatedSprite.animation = "acorn_silver"
			$Glow.show()
	
	size = get_node("AnimatedSprite").frames.get_frame("acorn_normal", 0).get_size() * scale

func _process(delta) -> void:
	
	if !passed && position.y < 255:
		
		passed = true
		get_parent().can_add_coin = true
	
	if eaten:
		if t_death > 0:
			scale = Vector2((t_death / 10.0) * 2, (t_death / 10.0) * 2)
			t_death -= 1
		else:
			queue_free()