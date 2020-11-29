extends Sprite

var branch_hspace
var has_vines : bool = false

func _ready() -> void:
	_cycle()

func _cycle() -> void:
	branch_hspace = 110 + g.random(100)

func set_has_vines(has_vines : bool) -> void:
	
	self.has_vines = has_vines
	for side in range(2):
		
		var vine_y = g.random(68)
		for i in range(3):
			
			var vine_i = get_node("Vine" + str(side) + str(i))
			vine_i.hide()
			if has_vines && vine_y <= branch_hspace / 2 - 34:
				
				vine_i.frame = g.random(5)
				vine_i.position.y = vine_y
				vine_i.show()
				vine_y += 34 + g.random(34)

func set_texture(new_texture : Texture) -> void:
	texture = new_texture
	$BranchEnd.texture = new_texture
