extends Node2D

var acorn_icon_frame : int = 0
var acorn_rarity : Array # [silver, gold, diamond]
var acorn_rarity_bit : bool = true # whether a diamond can spawn
var acorn_rarity_thres : int
var acorn_pitch : float = 1
var acorn_queue_active : int # the current generating queue (id)
var acorn_queue_combo : int # the current interacted queue (id)
var acorn_queue_size = {} # the amount of acorns left in a given queue -> queue completion sound effect
var acorn_xpos : int
var acorns : int
var area : int = 0 # 0 = forest; 1 = snow; 2 = jungle
var branch_worm_type : int # -1 = none; 0 = idle; 1 = moving; 2 = ambush
var distance : float
var game_over : bool = false
var hazard_free : bool = true  # whether a new hazard can be spawn
var hazard_type : int # 0 = falling apple; 1 = worm; 2 = ambush worm; 3 = giant work; 4 = area unique
var hazard_weights : Array = [10, 10]
	# [hazardApple, hazardWorm, hazardBigWorm, hazardSpecial] 
var queue_next : bool = true
var queue_next_i : int
var room_height : int = 280
var room_width : int = 160
var speed_cloud : int
var speed_tree : int
var t_acc : Object
var t_area : Object
var t_acorn : Object
var t_hazard : Object
var t_warning : Object

const ACORN = preload("res://Scenes/Acorn.tscn")
const ACORN_SOUND_COLLECT = preload("res://Sounds/acorn0galm.wav")
const ACORN_SOUND_DIAMOND = preload("res://Sounds/acorn_diamond0.wav")
const ACORN_SOUND_GOTALL = preload("res://Sounds/complete_queue0.wav")
const ACORN_TYPES = ["acorn_normal", "acorn_silver", "acorn_gold", "acorn_diamond"]
const ACORN_VALUES = [1, 3, 10, 50]
const TIMER = preload("res://Scripts/timer.gd")
const BRANCH_TYPES = [[preload("res://Textures/Backgrounds/branch_0.png"),
					   preload("res://Textures/Backgrounds/branch_1.png")],
					  [preload("res://Textures/Backgrounds/branch_winter_0.png"),
					   preload("res://Textures/Backgrounds/branch_winter_1.png")],
					  [preload("res://Textures/Backgrounds/branch_0.png"),
					   preload("res://Textures/Backgrounds/branch_1.png")]]

onready var branches = [$Background/Branch, $Background/Branch2,
						$Background/Branch3,$Background/Branch4]
onready var clouds = [$Background/Clouds, $Background/Clouds2]
onready var icon_acorn = $Overlay/IconAcorn
onready var player = $SoundPlayer
onready var tree = [$Background/Tree, $Background/Tree2, $Background/Tree3, $Background/Tree4]
onready var treeback1 = [$Background/Back, $Background/Back4]
onready var treeback2 = [$Background/Back2, $Background/Back5]
onready var treeback3 = [$Background/Back3, $Background/Back6]
onready var show_score = $Overlay/ShowScore
onready var show_acorns = $Overlay/ShowAcorns
onready var warning = $Overlay/WarningSign

func _ready():
	
	t_warning = TIMER.new()
	t_warning.init(1.5, 1, false, true)
	g.load_settings()
	game_start()

func _process(delta):
	
	check_keyboard()
	
	if !game_over:
		update_acorns()
	
	update_acorns()
	update_background(delta)
	update_distance(delta)
	update_music()
	update_timers(delta)

func check_keyboard() -> void:
	
	if Input.is_action_just_released("game_exit"):
		get_tree().quit()
	if Input.is_action_just_released("game_restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_released("game_spd1"):
		Engine.time_scale = 1
	if Input.is_action_just_released("game_spd2"):
		Engine.time_scale = 2
	if Input.is_action_just_released("game_spd4"):
		Engine.time_scale = 4

func collect_acorn(queue_id : int, type: int) -> void:
	
	acorn_queue_size[queue_id] -= 1
	
	if queue_id == acorn_queue_combo:
		acorn_pitch += 1 / 12.0
	else:
		acorn_pitch = 1.0
		acorn_queue_combo = queue_id
	collect_acorn_sound(queue_id, type)
	
	acorns += ACORN_VALUES[type]
	icon_acorn.animation = ACORN_TYPES[type]

func collect_acorn_sound(queue_id : int, type: int):
	
	player.pitch_scale = 1
	player.volume_db = 0
	
	if type < 3:
		
		if acorn_queue_size[queue_id] > 0:
			player.stream = ACORN_SOUND_COLLECT
			player.pitch_scale = acorn_pitch
		else:
			player.stream = ACORN_SOUND_GOTALL
			player.pitch_scale = 1
	else:
		player.stream = ACORN_SOUND_DIAMOND
		player.volume_db = 4
	
	player.play()

func create_acorn_queue(queue_length : int) -> void:
	
	var acorn_queue_id = 0
	while acorn_queue_id in acorn_queue_size:
		acorn_queue_id += 1
	acorn_queue_active = acorn_queue_id
	queue_next_i = queue_length
	acorn_queue_size[acorn_queue_id] = queue_length

func game_end() -> void:
	
	$Restart.show()
	if distance > g.distance_best: g.distance_best = distance
	g.save_settings()
	game_over = true

func game_start() -> void:
	
	pick_acorn_xpos(false)
	acorns = 0
	distance = 0
	acorn_rarity = [3, 8, 34] # 7+1; 31+3 accounted for non-appearing waves
	acorn_rarity_thres = 20
	
func init() -> void:
	
	pivot_coin_position(true)
	coins = 0
	coin_chance = [3, 8, 34] # 7+1; 31+3 accounted for non-appearing waves
	score = 0
	speed_cloud = 10
	speed_tree = 125
	t_acc = TIMER.new()
	t_acc.init(1.2)
	t_area = TIMER.new()
	t_area.init(45)
	t_acorn = TIMER.new()
	t_acorn.init(2)
	t_hazard = TIMER.new()
	t_hazard.init(1, 1, false)
	
	for i in get_children():
		if i.is_in_group("acorn") || i.is_in_group("hazard"):
			i.queue_free()
	
	for i in range(0, len(branches)):
		
		if i == 0:
			branches[0].position.y = g.random(room_height)
		else: branches[i].position.y = branches[i - 1].position.y + (140 + 40) 
		
		branches[i].texture = g.choose(BRANCH_TYPES[area])
	
	$Apple.show()
	$Restart.hide()
	
	randomize()

func get_new_acorn() -> int:
	
	if distance >= 20:
		if g.chance(acorn_rarity[0]):
			return 1
	if distance >= 40:
		if g.chance(acorn_rarity[1]):
			return 2
	if distance >= 60:
		if g.chance(acorn_rarity[2]) && acorn_rarity_bit == true:
			acorn_rarity_bit = false
			return 3
	return 0

func pick_acorn_xpos(relative : bool = true) -> void:
	
	if relative:
		
		if g.chance(3):
			acorn_xpos = g.normal(acorn_xpos + g.choose([-20, 20]), \
				0, room_width - 20)
	else:
		acorn_xpos = 20 * g.random(7)

func restart_game() -> void:
	game_over = false
	game_start()

func set_area(new_area : int) -> void:
	
	area = new_area
	$MusicPlayer.stream = load("res://Sounds/Music/soundtrack" + str(new_area) + ".wav")
	
	match area:
		
		0:
			$Background/Canvas.texture = load("res://Textures/Backgrounds/back_forest_3.png")
			for i in tree:
				i.texture = load("res://Textures/Backgrounds/bark.png")
			for i in treeback1:
				i.texture = load("res://Textures/Backgrounds/back_forest_0.png")
			for i in treeback2:
				i.texture = load("res://Textures/Backgrounds/back_forest_1.png")
			for i in treeback3:
				i.texture = load("res://Textures/Backgrounds/back_forest_2.png")
				i.show()
		1:
			$Background/Canvas.texture = load("res://Textures/Backgrounds/back_winter_3.png")
			for i in tree:
				i.texture = load("res://Textures/Backgrounds/bark_winter.png")
			for i in treeback1:
				i.texture = load("res://Textures/Backgrounds/back_winter_0.png")
			for i in treeback2:
				i.texture = load("res://Textures/Backgrounds/back_winter_1.png")
			for i in treeback3:
				i.hide()

func show_warning(pos : Vector2) -> void:
	
	warning.show()
	warning.position = pos
	t_warning.reset()

func spawn_hazard() -> void:
	
	match(g.choose_weighted(hazard_weights)):
		0: spawn_hazard_apple()
		1: spawn_hazard_worm(g.random(2))

func spawn_hazard_apple() -> void:
	
	var xpos = g.random(4) * 32
	show_warning(Vector2(xpos + 16, 32))
	
	var new_hazard_apple = load("res://Scenes/HazardApple.tscn").instance()
	new_hazard_apple.position = Vector2(xpos, -180)
	add_child(new_hazard_apple)

# @param type: 0 = idle; 1 = moving; 2 = ambush
func spawn_hazard_worm(type : int) -> void:
	branch_worm_type = type

func update_acorns() -> void:
	
	if acorn_queue_active in acorn_queue_size:
		
		if queue_next_i > 0:
			
			if queue_next:
				
				queue_next = false
				
				queue_next_i -= 1
				pick_acorn_xpos()
				var new_acorn = ACORN.instance()
				new_acorn.position = Vector2(acorn_xpos, room_height + 6)
				new_acorn.queue_id = acorn_queue_active
				add_child(new_acorn)
			
		else:
			acorn_queue_active = -1
			t_acorn.init(2 + g.random(4), 1, false)

func update_area() -> void:
	
	var new_area = g.random(1)
	while new_area == area:
		new_area = g.random(1)
	set_area(new_area)

func update_background(delta) -> void:
	
	#update_area()
	update_background_tree(delta)
	
	for i in clouds:
		i.position.x += speed_cloud * delta
		if i.position.x > room_width:
			i.position.x -= room_width * 2
	
	if game_over:
		if speed_tree > 0:
			speed_tree -= 2
		else:
			speed_tree = 0

func update_background_tree(delta) -> void:
	
	# trunk movement
	for i in tree:
		i.position.y -= speed_tree * delta
		if i.position.y <= -room_height:
			i.position.y += room_height * 2
	
	# backtree movement
	for i in treeback1:
		i.position.y -= speed_tree * delta * (60.0 / 100)
		if i.position.y <= -room_height:
			i.position.y += room_height * 2
	for i in treeback2:
		i.position.y -= speed_tree * delta * (50.0 / 100)
		if i.position.y <= -room_height:
			i.position.y += room_height * 2
	for i in treeback3:
		i.position.y -= speed_tree * delta * (40.0 / 100)
		if i.position.y <= -room_height:
			i.position.y += room_height * 2
	
	# branch movement
	for i in branches:
		i.position.y -= speed_tree * delta
		if i.position.y <= -111:
			i.position.y = branches[(branches.find(i) - 1 % 4)].position.y + (110 + g.random(100))
			i.texture = g.choose(BRANCH_TYPES[area])

func update_music() -> void:
	
	if $MusicPlayer.playing == false:
		$MusicPlayer.play()

func update_distance(delta) -> void:
	
	distance += speed_tree * delta * 0.003125
	
	show_score.text = str(stepify(distance, 0.1))
	show_acorns.text = str(acorns)
	$Overlay/ShowArea.text = "area 0" + str(area)
	
	# update acorn rarity
	if distance >= acorn_rarity_thres:
		for i in len(acorn_rarity):
			if acorn_rarity[i] > 0 + int(i == 2):
				acorn_rarity[i] -= 1
		acorn_rarity_thres += 20
		
	if acorn_icon_frame < 96:
		acorn_icon_frame += 1
	else:
		acorn_icon_frame = 0
	icon_acorn.frame = floor(acorn_icon_frame / 12.0)

func update_timers(delta) -> void:
	
	if t_acorn.advance(delta):
		pick_acorn_xpos(false)
		create_acorn_queue(4 + g.random(8))
	
	if t_area.advance(delta):
		update_area()
	
	if !game_over:
		
		if t_acc.advance(delta):
			speed_tree += 1
		if t_hazard.advance(delta):
			spawn_hazard()
		if t_warning.advance(delta):
			warning.hide()
