extends Node2D

var area : int = 0 # 0 = forest; 1 = snow; 2 = jungle
var branch_worm_type : int # -1 = none; 0 = idle; 1 = moving; 2 = ambush
var can_add_coin : bool = true
var coin_chance : Array 
var coin_icon_frame : int = 0
var coin_position : int
var coin_rarity_bit : bool = true # whether a diamond can spawn
var coin_pitch : float = 1
var coin_queue : int = 0
var coin_queue_id : int = -1
var coin_queue_left = [0, 0, 0] # the amount of coins left in the queue -> queue completion sound effect
var coin_queue_last : int # the last queue (id) eaten from
var coin_thres : int = 20
var coins : int
var game_over : bool = false
var hazard_free : bool = true  # whether a new hazard can be spawn
var hazard_type : int # 0 = falling apple; 1 = worm; 2 = ambush worm; 3 = giant work; 4 = area unique
var hazard_weights : Array = [10, 10]
	# [hazardApple, hazardWorm, hazardBigWorm, hazardSpecial] 
var room_height : int = 280
var room_width : int = 160
var score : float
var speed_cloud : int
var speed_tree : int
var t_area : int
var t_branch : int
var t_coin : int
var t_enemy : int
var t_hazard : int
var t_speed : int
var t_warning : int
const T_area : int = 2500
const T_enemy : int = 100

onready var branch_types = [[load("res://Textures/Backgrounds/branch_0.png"),
							 load("res://Textures/Backgrounds/branch_1.png")],
							[load("res://Textures/Backgrounds/branch_winter_0.png"),
							 load("res://Textures/Backgrounds/branch_winter_1.png")],
							[load("res://Textures/Backgrounds/branch_0.png"),
							 load("res://Textures/Backgrounds/branch_1.png")]]
onready var branches = [$Background/Branch, $Background/Branch2,
						$Background/Branch3,$Background/Branch4]
onready var clouds = [$Background/Clouds, $Background/Clouds2]
onready var tree = [$Background/Tree, $Background/Tree2, $Background/Tree3, $Background/Tree4]
onready var treeback1 = [$Background/Back, $Background/Back4]
onready var treeback2 = [$Background/Back2, $Background/Back5]
onready var treeback3 = [$Background/Back3, $Background/Back6]
onready var show_score = $GUI/ShowScore
onready var show_coins = $GUI/ShowCoins
onready var warning = $GUI/WarningSign

func _ready():
	
	g.load_settings()
	init()

func _process(delta):
	
	check_keyboard()
	
	if !game_over:
		spawn_entities()
		update_game_speed()
	
	update_background(delta)
	update_music()
	update_score(delta)
	update_timers()

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

func end_game() -> void:
	
	$Restart.show()
	if score > g.highscore: g.highscore = score
	g.save_settings()
	game_over = true

func init() -> void:
	
	pivot_coin_position(true)
	coins = 0
	coin_chance = [3, 8, 34] # 7+1; 31+3 accounted for non-appearing waves
	score = 0
	speed_cloud = 10
	speed_tree = 125
	t_area = T_area
	t_coin = 100
	t_enemy = T_enemy
	
	for i in get_children():
		if i.is_in_group("coin") || i.is_in_group("hazard"):
			i.queue_free()
	
	for i in range(0, len(branches)):
		
		if i == 0:
			branches[0].position.y = g.random(room_height)
		else: branches[i].position.y = branches[i - 1].position.y + (140 + 40) 
		
		branches[i].texture = g.choose(branch_types[area])
	
	$Apple.show()
	$Restart.hide()
	
	randomize()

func pivot_coin_position(scramble : bool) -> void:
	
	if scramble:
		coin_position = 20 * g.random(7)
	elif g.random(2) == 0:
		coin_position += g.choose([-20, 20])
		
	if coin_position < 0:
		coin_position = 0
	if coin_position > room_width - 20:
		coin_position = room_width - 20

func restart_game() -> void:
	
	game_over = false
	init()

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

func set_coin_queue(queue_lenght : int) -> void:
	coin_queue = queue_lenght
	coin_queue_id = (coin_queue_id + 1) % 3
	coin_queue_left[coin_queue_id] = queue_lenght
	if coin_queue_id == coin_queue_last:
		coin_queue_last = -1

func show_warning(pos : Vector2) -> void:
	
	warning.show()
	warning.position = pos
	t_warning = 60

func spawn_entities() -> void:
	
	spawn_coins()
	spawn_hazards()
	
func spawn_coins() -> void:
	
	if coin_queue > 0:
		
		if can_add_coin:
			
			can_add_coin = false
			coin_queue -= 1
			pivot_coin_position(false)
			
			var new_coin = load("res://Scenes/Coin.tscn").instance()
			new_coin.position = Vector2(coin_position, room_height + 6)
			new_coin.queue_id = coin_queue_id
			add_child(new_coin)
		
	else:
		
		if coin_queue <= 0 && t_coin > 0:
			t_coin -= 1
			
		else: 
			t_coin = 30 + g.random(30)
			pivot_coin_position(true)
			if g.random(1) == 0: set_coin_queue(4 + g.random(8))

func spawn_hazards() -> void:
	
	if hazard_free:
		
		if t_hazard < 60:
			t_hazard += 1
		else:
			t_hazard = 0
			
			match(g.choose_weighted(hazard_weights)):
				
				0: spawn_hazards_apple()
				1: spawn_hazards_worm(g.random(2))
			
			hazard_free = false

func spawn_hazards_apple() -> void:
	
	var xpos = g.random(4) * 32
			
	show_warning(Vector2(xpos + 16, 32))
	
	var new_hazard_apple = load("res://Scenes/HazardApple.tscn").instance()
	new_hazard_apple.position = Vector2(xpos, -180)
	add_child(new_hazard_apple)

# @param type: 0 = idle; 1 = moving; 2 = ambush
func spawn_hazards_worm(type : int) -> void:
	
	branch_worm_type = type

func update_area() -> void:
	
	if t_area > 0:
		t_area -= 1
	else:
		var new_area = g.random(1)
		while new_area == area:
			new_area = g.random(1)
		
		set_area(new_area)
		
		t_area = T_area

func update_background(delta) -> void:
	
	update_area()
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
			i.texture = g.choose(branch_types[area])

func update_game_speed() -> void:
	
	if t_speed < 70:
		t_speed += 1
	else:
		t_speed = 0
		speed_tree += 1

func update_music() -> void:
	
	if $MusicPlayer.playing == false:
		$MusicPlayer.play()

func update_score(delta) -> void:
	
	score += speed_tree * delta * 0.003125
	
	show_score.text = str(stepify(score, 0.1))
	show_coins.text = str(coins)
	$GUI/ShowArea.text = "area 0" + str(area)
	
	# update coin frequency
	if score >= coin_thres:
		for i in len(coin_chance):
			if coin_chance[i] > 0 + int(i == 2):
				coin_chance[i] -= 1
		coin_thres += 20
		
	if coin_icon_frame < 96:
		coin_icon_frame += 1
	else:
		coin_icon_frame = 0
	$GUI/CoinIcon.frame = floor(coin_icon_frame / 12.0)

func update_timers() -> void:
	
	if t_warning != -1:
		if t_warning > 0:
			t_warning -= 1
		else:
			t_warning = -1
			warning.hide()
