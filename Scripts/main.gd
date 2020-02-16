extends Node2D

var can_add_coin : bool = true
var coin_chance : Array 
var coin_icon_frame : int = 0
var coin_position : int
var coin_rarity_bit : bool = true # whether a diamond can still join the queue (only 1 per)
var coin_queue : int = 0
var coin_thres : int = 20
var coins : int
var game_over : bool = false
var room_height : int = 280
var room_width : int = 160
var score : float
var speed_cloud : int
var speed_tree : int
var t_coin : int
var t_enemy : int
var t_speed : int

onready var clouds = [$Clouds, $Clouds2]
onready var tree = [$Tree, $Tree2]
onready var show_score = $GUI/ShowScore
onready var show_coins = $GUI/ShowCoins

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
	score = 2000
	speed_cloud = 10
	speed_tree = 100
	t_coin = 100
	t_enemy = 100
	
	for i in get_children():
		if i.is_in_group("coin") || i.is_in_group("enemy"):
			i.queue_free()
	
	$Apple.show()
	$Restart.hide()
	
	randomize()

func pivot_coin_position(scramble : bool) -> void:
	
	if scramble:
		coin_position = 10 + 20 * g.random(7)
	elif g.random(2) == 0:
		coin_position += g.choose([-20, 20])
		
	if coin_position < 10:
		coin_position = 10
	if coin_position > 150:
		coin_position = 150

func restart_game() -> void:
	
	game_over = false
	init()

func set_coin_queue(value) -> void:
	coin_queue = value
	coin_rarity_bit = true

func spawn_entities() -> void:
	
	if coin_queue > 0:
		
		if can_add_coin:
			
			can_add_coin = false
			coin_queue -= 1
			pivot_coin_position(false)
			
			var new_coin = load("res://Scenes/Coin.tscn").instance()
			new_coin.position = Vector2(coin_position, room_height + 6)
			add_child(new_coin)
		
	else:
		
		if coin_queue <=0 && t_coin > 0:
			t_coin -= 1
			
		else: 
			t_coin = 30 + g.random(30)
			pivot_coin_position(true)
			if g.random(1) == 0: set_coin_queue(4 + g.random(8))
	
#	if t_enemy > 0:
#		t_enemy -= 1
#
#	else:
#
#		if g.random(6 - int(score > 50) - int(score > 100) - int(score > 150)) == 0:
#
#			var new_enemy = load("res://Scenes/Enemy.tscn").instance()
#			new_enemy.position = Vector2(8 + g.random(room_width - 16), 148)
#			add_child(new_enemy)
#
#		t_enemy = 25

func update_background(delta) -> void:
	
	for i in tree:
		i.position.y -= speed_tree * delta
		if i.position.y <= -room_height:
			i.position.y += room_height * 2
			
	for i in clouds:
		i.position.x += speed_cloud * delta
		if i.position.x > room_width:
			i.position.x -= room_width * 2
	
	if game_over:
		if speed_tree > 0:
			speed_tree -= 2
		else:
			speed_tree = 0

func update_game_speed() -> void:
	
	if t_speed < 50:
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
	
	# update coin frequency
	if score >= coin_thres:
		for i in len(coin_chance):
			if coin_chance[i] > 0:
				coin_chance[i] -= 1
		coin_thres += 20
		
	if coin_icon_frame < 96:
		coin_icon_frame += 1
	else:
		coin_icon_frame = 0
	$GUI/CoinIcon.frame = floor(coin_icon_frame / 12.0)
