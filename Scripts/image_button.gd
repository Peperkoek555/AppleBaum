extends Sprite

signal pressed

export (String) var tag

onready var images : Array

func _ready() -> void:
	
	images = [load("res://Textures/" + tag + "_0.png"),
			  load("res://Textures/" + tag + "_1.png")]
	set_toggled(false)

func _pressed():
	emit_signal("pressed")

func set_toggled(is_toggled : bool) -> void:
	texture = images[int(is_toggled)]
