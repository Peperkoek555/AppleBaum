extends Node2D

const NO_LAYERS = 3

func _ready():
	create_layers()

func create_layers() -> void:
	
	var parents = [$Rain0, $WindParticles0]
	for i in range(NO_LAYERS - 1):
		
		var z_idx = -11 - i
		var hue_shift = 1 - i * 0.15
		for P in parents:
			
			var NewParticle = P.duplicate()
			NewParticle.initial_velocity = P.initial_velocity - (i + 1)
			NewParticle.modulate = Color(hue_shift, hue_shift, hue_shift, 1)
			NewParticle.name = P.name.left(P.name.length() - 1) + str(i + 1)
			NewParticle.preprocess = 5 + g.randomf(5)
			NewParticle.scale_amount = 2 - i * 0.5
			NewParticle.z_index = z_idx
			NewParticle.show()
			add_child(NewParticle)

func set_area(area : String) -> void:
	
	for i in range(NO_LAYERS):
		
		var R = get_node("Rain" + str(i))
		var W = get_node("WindParticles" + str(i))
		
		match area:
		
			"forest":
				
				R.hide()
				
				W.show()
				W.amount = 9
				W.material.particles_anim_h_frames = 6
				W.texture = load("res://Textures/particles_" + area + ".png")
			
			"winter":
				
				R.hide()
				
				W.show()
				W.amount = 11
				W.material.particles_anim_h_frames = 7
				W.texture = load("res://Textures/particles_" + area + ".png")
			
			"jungle":
				R.show()
				W.hide()
