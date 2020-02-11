extends Node2D

var can_add_coin : bool = true
var coin_position : int
var coin_queue : int = 0
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
	if Input.is_action_just_released("exit_game"):
		get_tree().quit()

func end_game() -> void:
	
	$Restart.show()
	if score > g.highscore: g.highscore = score
	g.save_settings()
	game_over = true

func init() -> void:
	
	pivot_coin_position(true)
	coins = 0
	score = 0
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
			if g.random(1) == 0: coin_queue = 4 + g.random(8)
	
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
