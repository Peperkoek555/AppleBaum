extends "res://Scripts/entity.gd"

var eaten : bool
var passed : bool # whether the coin passed the threshold to let in a new coin
var ordinal : int = 0
var queue_id : int
var type : int = 0 # 0 = normal; 1 = silver; 2 = gold: 3 = diamond
var t_death : float = 10

func _ready():
	
	if main.score >= 20:
		if g.random(main.coin_chance[0]) == 0:
			type = 1
			$AnimatedSprite.animation = "acorn_silver"
			$Glow.animation = "glow_silver"
			$Glow.show()
	if main.score >= 40:
		if g.random(main.coin_chance[1]) == 0:
			type = 2
			$AnimatedSprite.animation = "acorn_gold"
			$Glow.animation = "glow_gold"
			$Glow.show()
	if main.score >= 60:
		if g.random(main.coin_chance[2]) == 0 && main.coin_rarity_bit == true:
			type = 3
			main.coin_rarity_bit = false
			$AnimatedSprite.animation = "acorn_diamond"
			$Glow.animation = "glow_diamond"
			$Glow.show()
	
	size = Vector2(20, 20)

func _process(delta) -> void:
	
	if !passed && position.y < 265:
		
		passed = true
		main.can_add_coin = true
	
	if eaten:
		if t_death > 0:
			$AnimatedSprite.scale = Vector2(t_death / 10.0, t_death / 10.0)
			t_death -= 1
		else:
			destroy()

func destroy() -> void:
	if type == 3: main.coin_rarity_bit = true
	.destroy()
