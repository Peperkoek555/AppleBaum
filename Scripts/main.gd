extends Node2D

var acorn_icon_type : int = 0
var acorn_rarity : Array # [normal, silver, gold, diamond]
var acorn_rarity_bit : bool = true # whether a diamond can spawn
var acorn_rarity_thres : int
var acorn_pitch : float = 1
var acorn_queue_active : int # the current generating queue (id)
var acorn_queue_combo : int # the current interacted queue (id)
var acorn_queue_size = {} # the amount of acorns left in a given queue -> queue completion sound effect
var acorn_xpos : int
var acorns : int
var area : String
var branch_worm_type : int # -1 = none; 0 = idle; 1 = moving; 2 = ambush
var current_player : int = 0 # current music player
var distance : float
var enemy_type : int
var enemy_weights : Array = [10]
var fall_speed : int
var game_over : bool = false
var queue_next : bool = true
var queue_next_i : int
var speed_cloud : int
var t_acc : Object
var t_area : Object
var t_acorn : Object
var t_enemy : Object
var t_music_trans : Object
var t_warning : Object

const ACORN = preload("res://Scenes/Acorn.tscn")
const ACORN_SOUND_COLLECT = preload("res://Sounds/acorn0galm.wav")
const ACORN_SOUND_DIAMOND = preload("res://Sounds/acorn_diamond0.wav")
const ACORN_SOUND_GOTALL = preload("res://Sounds/complete_queue0.wav")
const ACORN_TYPES = ["acorn_normal", "acorn_silver", "acorn_gold", "acorn_diamond"]
const ACORN_VALUES = [1, 3, 10, 50]
const AREA_TYPES = ["forest", "winter", "jungle"]
const BRANCH_TYPES = {
	"forest": [preload("res://Textures/Backgrounds/branch_0.png"),
				preload("res://Textures/Backgrounds/branch_1.png")],
	"winter": [preload("res://Textures/Backgrounds/branch_winter_0.png"),
				preload("res://Textures/Backgrounds/branch_winter_1.png")],
	"jungle": [preload("res://Textures/Backgrounds/branch_jungle_0.png"),
				preload("res://Textures/Backgrounds/branch_jungle_1.png")]
}
const CANVAS_COLORS = {
	"forest": Color8(45, 66, 56),
	"winter": Color8(181, 200, 213),
	"jungle": Color.white
}
enum ENEMY_TYPES {
	DEFAULT
}
const ROOM_H = 280
const ROOM_W = 160
const TIMER = preload("res://Scripts/timer.gd")

onready var bark = [$Background/Tree00, $Background/Tree01,
					$Background/Tree10, $Background/Tree11]
onready var branches = [$Background/Branch0, $Background/Branch1,
						$Background/Branch2,$Background/Branch3]
onready var canv_trees0 = [$Background/Back00, $Background/Back10]
onready var canv_trees1 = [$Background/Back01, $Background/Back11]
onready var canv_trees2 = [$Background/Back02, $Background/Back12]
onready var canv_trees3 = [$Background/Back03, $Background/Back13]
onready var clouds = [$Background/Clouds, $Background/Clouds2]
onready var icon_acorn = $Overlay/IconAcorn
onready var particles = [$Background/ParticlesBack, $Overlay/ParticlesFront]
onready var player = $SoundPlayer
onready var player_long = $SoundPlayerLong
onready var show_score = $Overlay/ShowScore
onready var show_acorns = $Overlay/ShowAcorns
onready var vines = [$Background/Vines00, $Background/Vines01]
onready var warning = $Overlay/WarningSign

func _ready():
	
	t_music_trans = TIMER.new()
	t_music_trans.init(3, 0, false, true)
	t_warning = TIMER.new()
	t_warning.init(1.5, 0, false, true)
	g.load_settings()
	game_start()

func _process(delta):
	
	check_keyboard()
	
	if !game_over:
		update_acorns()
	
	update_distance(delta)
	update_movement(delta)
	update_timers(delta)

func _player_ended(index : int) -> void:
	if index == current_player:
		update_music(true)

func _enemy_destroyed() -> void:
	t_enemy.reset()

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
	if type != acorn_icon_type:
		
		var oldframe = icon_acorn.frame
		icon_acorn.animation = ACORN_TYPES[type]
		icon_acorn.frame = oldframe
		acorn_icon_type = type

func collect_acorn_sound(queue_id : int, type: int):
	
	if type < 3:
		
		if acorn_queue_size[queue_id] > 0:
			player.stream = ACORN_SOUND_COLLECT
			player.pitch_scale = acorn_pitch
		else:
			player.stream = ACORN_SOUND_GOTALL
			player.pitch_scale = 1
		player.play()
	else:
		player_long.stream = ACORN_SOUND_DIAMOND
		player_long.play()

func create_acorn_queue(queue_length : int) -> void:
	
	var acorn_queue_id = 0
	while acorn_queue_id in acorn_queue_size:
		acorn_queue_id += 1
	acorn_queue_active = acorn_queue_id
	queue_next_i = queue_length
	acorn_queue_size[acorn_queue_id] = queue_length

func game_end() -> void:
	
	$Overlay/Restart.show()
	if distance > g.distance_best: g.distance_best = distance
	g.save_settings()
	game_over = true

func game_start() -> void:
	
	game_over = false
	randomize()
	
	set_area("jungle")
	update_acorn_xpos(false)
	acorns = 0
	distance = 0
	acorn_rarity = [30, 0, 0, 0]
	acorn_rarity_thres = 5
	fall_speed = 125
	speed_cloud = 10
	init_timers()
	
	for i in get_children():
		if i.is_in_group("acorns") || i.is_in_group("enemies"):
			i.queue_free()
	
	$Apple.show()
	$Overlay/Restart.hide()

func init_timers() -> void:
	
	t_acc = TIMER.new()
	t_acc.init(1.2)
	t_area = TIMER.new()
	t_area.init(45)
	t_acorn = TIMER.new()
	t_acorn.init(2, 2, false)
	t_enemy = TIMER.new()
	t_enemy.init(1, 0, false)

func set_area(area : String) -> void:
	
	self.area = area
	
	# particles
	for i in particles:
		i.texture = load("res://Textures/particles_" + area + ".png")
		i.material.particles_anim_h_frames = \
			6 + int(area == "winter")
		i.amount = 3 + int(area == "winter")*13
	
	set_area_background(area)
	update_music(false, get_node("MusicPlayer" + str(current_player)).get_playback_position())

func set_area_background(area : String) -> void:
	
	$Background/Canvas/Canvas.color = CANVAS_COLORS[area]
	for i in bark:
		i.texture = load("res://Textures/Backgrounds/bark_" + area + ".png")
	for i in canv_trees0:
		i.texture = load("res://Textures/Backgrounds/back_" + area + "_0.png")
	for i in canv_trees1:
		i.texture = load("res://Textures/Backgrounds/back_" + area + "_1.png")
	for i in canv_trees2:
		
		if area == "forest" || area == "jungle":
			i.texture = load("res://Textures/Backgrounds/back_" + area + "_2.png")
			i.show()
		else: i.hide()
		
	for i in canv_trees3:
		
		if area == "jungle":
			i.texture = load("res://Textures/Backgrounds/back_" + area + "_3.png")
			i.show()
		else: i.hide()
	
	# branches
	for i in range(4):
		
		if i == 0: 
			branches[0].position.y = g.random(ROOM_H)
		else: 
			branches[i].position.y = branches[i - 1].position.y + (140 + 40) 
		
		branches[i].texture = g.choose(BRANCH_TYPES[area])
	
	# vines
	for i in range(2):
		
		if area == "jungle":
			spawn_vines(vines[i], branches[i + 2 * int(g.chance(2))].position.y) 
			vines[i].show()
		else: vines[i].hide()

func show_warning(pos : Vector2) -> void:
	
	warning.position = pos
	warning.show()
	t_warning.reset()

func spawn_enemy() -> void:
	
	var new_enemy_type : int = g.choose_weighted(enemy_weights)
	match(new_enemy_type):
		
		0:
			var enemy_default = load("res://Scenes/EnemyDefault.tscn").instance()
			enemy_default.position = \
				Vector2(g.random(4) * (ROOM_W / 5), ROOM_H + 32)
			add_child(enemy_default)
	
	enemy_type = new_enemy_type

func spawn_vines(vines : Object, on_branch_pos_y : int) -> void:
	vines.position.y = on_branch_pos_y + 72

func update_acorns() -> void:
	
	if acorn_queue_active in acorn_queue_size:
		
		if queue_next_i > 0:
			
			if queue_next:
				
				queue_next = false
				queue_next_i -= 1
				update_acorn_xpos()
				# create acorn
				var new_acorn = ACORN.instance()
				new_acorn.position = Vector2(acorn_xpos, ROOM_H + 6)
				new_acorn.queue_id = acorn_queue_active
				add_child(new_acorn)
			
		else:
			acorn_queue_active = -1
			t_acorn.reset()

func update_acorn_xpos(relative : bool = true) -> void:
	
	if relative:
		
		if g.chance(3):
			acorn_xpos = g.normal(acorn_xpos + g.choose([-20, 20]), \
				0, ROOM_W - 20)
	else:
		acorn_xpos = 20 * g.random(7)

func update_area() -> void:
	
	var new_area = g.choose(AREA_TYPES)
	while new_area == area:
		new_area = g.choose(AREA_TYPES)
	set_area(new_area)

func update_distance(delta) -> void:
	
	distance += fall_speed * delta * 0.003125
	
	show_score.text = str(stepify(distance, 0.1))
	show_acorns.text = str(acorns)
	
	# update acorn rarity
	if distance >= acorn_rarity_thres:
		for i in range(1, len(acorn_rarity)):
			if distance >= 20 * i:
				acorn_rarity[i] += 10
				# diamond
				if i == 3: acorn_rarity[i] = floor(acorn_rarity[1] / 30)
		acorn_rarity_thres += 20

func update_movement(delta) -> void:
	
	if game_over:
		if fall_speed > 0:
			fall_speed -= 2
		else:
			fall_speed = 0
	
	update_movement_tree(delta)

func update_movement_tree(delta) -> void:
	
	var movement = fall_speed * delta
	
	# bark movement
	for i in bark:
		i.position.y -= movement
		if i.position.y <= -ROOM_H:
			i.position.y += ROOM_H * 2
	
	# branch movement
	for i in range(4):
		
		branches[i].position.y -= movement
		if branches[i].position.y <= -ROOM_H:
			
			branches[i].position.y = branches[(i - 1) % 4].position.y + (110 + g.random(100))
			branches[i].texture = g.choose(BRANCH_TYPES[area])
			
			if area == "jungle":
				
				var local_vines = vines[i % 2] # vines with same mirror
				if local_vines.position.y <= -268 && g.chance(2):
					spawn_vines(local_vines, branches[i].position.y)
	
	# vine movement
	if area == "jungle":
		
		for i in vines:
			if i.position.y > -268:
				i.position.y -= movement
	
	# paralax back movement
	for i in canv_trees0:
		i.position.y -= movement * (60.0 / 100)
		if i.position.y <= -ROOM_H:
			i.position.y += ROOM_H * 2
	for i in canv_trees1:
		i.position.y -= movement * (50.0 / 100)
		if i.position.y <= -ROOM_H:
			i.position.y += ROOM_H * 2
	for i in canv_trees2:
		i.position.y -= movement * (40.0 / 100)
		if i.position.y <= -ROOM_H:
			i.position.y += ROOM_H * 2

func update_music(is_loop : bool = true, start : float = 0.0) -> void:
	
	if !is_loop:
		current_player = (current_player + 1) % 2
		get_node("MusicPlayer" + str(current_player)).volume_db = -20
		get_node("MusicPlayer" + str(current_player)).stream = \
			load("res://Sounds/Music/ost_" + area + ".wav")
		t_music_trans.reset()
	get_node("MusicPlayer" + str(current_player)).play(start)

func update_timers(delta) -> void:
	
	if t_acorn.advance(delta):
		create_acorn_queue(4 + g.random(8))
		update_acorn_xpos(false)
	
	if t_area.advance(delta):
		update_area()
	
	if t_music_trans.advance_active(delta):
		
		get_node("MusicPlayer" + str(current_player)).volume_db = \
			g.db(t_music_trans.get_progress(), -3)
		get_node("MusicPlayer" + str((current_player + 1) % 2)).volume_db = \
			g.db(1 - t_music_trans.get_progress(), -3)
		if t_music_trans.is_full(): 
			get_node("MusicPlayer" + str((current_player + 1) % 2)).stop()
	
	if !game_over:
		
		if t_acc.advance(delta):
			fall_speed += 1
		if t_enemy.advance(delta):
			pass
			#spawn_enemy()
		if t_warning.advance(delta):
			warning.hide()
