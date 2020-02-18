extends "res://Scripts/entity.gd"

var eaten : bool
var passed : bool # whether the coin passed the threshold to let in a new coin
var ordinal : int = 0
var type : int = 0 # 0 = normal; 1 = silver; 2 = gold: 3 = diamond
var t_death : float = 10

func _ready():
	
	if get_parent().score >= 20:
		if g.random(get_parent().coin_chance[0]) == 0:
			type = 1
			$AnimatedSprite.animation = "acorn_silver"
			$Glow.animation = "glow_silver"
			$Glow.show()
	if get_parent().score >= 40:
		if g.random(get_parent().coin_chance[1]) == 0:
			type = 2
			$AnimatedSprite.animation = "acorn_gold"
			$Glow.animation = "glow_gold"
			$Glow.show()
	if get_parent().score >= 60:
		if g.random(get_parent().coin_chance[2]) == 0 && get_parent().coin_rarity_bit == true:
			type = 3
			get_parent().coin_rarity_bit = false
			$AnimatedSprite.animation = "acorn_diamond"
			$Glow.animation = "glow_diamond"
			$Glow.show()
	
	size = get_node("AnimatedSprite").frames.get_frame("acorn_normal", 0).get_size() * scale

func _process(delta) -> void:
	
	if !passed && position.y < 265:
		
		passed = true
		get_parent().can_add_coin = true
	
	if eaten:
		if t_death > 0:
			scale = Vector2((t_death / 10.0) * 2, (t_death / 10.0) * 2)
			t_death -= 1
		else:
			destroy()

func destroy() -> void:
	if type == 3: get_parent().coin_rarity_bit = true
	.destroy()
