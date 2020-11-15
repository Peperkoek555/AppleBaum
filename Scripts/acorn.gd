extends "res://Scripts/passing_object.gd"

var is_eaten : bool
var passed : bool # whether the acorn passed the threshold to let in a new acorn
var ordinal : int = 0
var queue_id : int
var type : int # 0 = normal; 1 = silver; 2 = gold: 3 = diamond
var t_death : float = 10

func _ready():
	
	type = g.choose_weighted(main.acorn_rarity)
	match type:
		1:
			$AnimatedSprite.animation = "acorn_silver"
			$Glow.animation = "glow_silver"
			$Glow.show()
		2:
			$AnimatedSprite.animation = "acorn_gold"
			$Glow.animation = "glow_gold"
			$Glow.show()
		3:
			$AnimatedSprite.animation = "acorn_diamond"
			$Glow.animation = "glow_diamond"
			$Glow.show()
	size = Vector2(20, 20)

func _process(delta) -> void:
	
	if !passed && position.y < 265:
		
		passed = true
		main.queue_next = true
	
	if is_eaten:
		if t_death > 0:
			$AnimatedSprite.scale = Vector2(t_death / 10.0, t_death / 10.0)
			t_death -= 1
		else:
			_destroyed()

func _destroyed() -> void:
	if type == 3: main.acorn_rarity_bit = true
	._destroyed()
