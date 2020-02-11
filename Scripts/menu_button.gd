extends Button

export var type : int = 0 # 0 = restart

var images = [load("res://Textures/retry_0.png"),
			  load("res://Textures/retry_1.png")]

func _ready() -> void:
	
	set_toggled(false)

func press() -> void:
	get_parent().restart_game()

func set_toggled(is_toggled : bool) -> void:
	
	$Sprite.texture = images[type + int(is_toggled)]
