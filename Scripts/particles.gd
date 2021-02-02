extends Node2D

func _ready():
	create_layers()

func create_layers() -> void:
	
	var front_particles = [$Rain, $WindParticles]
	for i in range(2): # 2 additional layers
		
		var z = -10 - i
		var hue_shift = 1 - i * 0.15
		for J in front_particles:
			
			var NewParticle = J.duplicate()
			#NewParticle.modulate = Color(hue_shift, hue_shift, hue_shift, 1)
			NewParticle.name = str(i)
			NewParticle.scale_amount = 2 - i * 0.2
			NewParticle.visible = true
			NewParticle.z_as_relative = false
			NewParticle.z_index = z
			print(NewParticle)
			J.add_child(NewParticle)

func set_area(area : String) -> void:
	
	match area:
		
		"forest":
			
			$Rain.hide()
			$WindParticles.show()
			
			for i in [$WindParticles] + $WindParticles.get_children():
				i.amount = 8
				i.material.particles_anim_h_frames = 6
				i.texture = load("res://Textures/particles_" + area + ".png")
		
		"winter":
			
			$Rain.hide()
			$WindParticles.show()
		
			for i in [$WindParticles] + $WindParticles.get_children():
				i.amount = 10
				i.material.particles_anim_h_frames = 7
				i.texture = load("res://Textures/particles_" + area + ".png")
		
		"jungle":
			$Rain.show()
			$WindParticles.hide()
