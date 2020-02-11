extends Node

const SAVE_PATH = "res://config.cfg"
var _config_file = ConfigFile.new()

var highscore : int = 0

func load_settings() -> void:
	
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print("Failed loading settings file. Error code %s"% error)
	
	highscore = _config_file.get_value("highscore", "highscore",  highscore)

func save_settings() -> void:
	
	_config_file.set_value("highscore", "highscore", highscore)
	_config_file.save(SAVE_PATH)

#---------------------------GENERAL-FUNCTION-LIBRARY-------------------------------#

# returns -1 for false; 1 for true
func bool2sign(b : bool) -> int:
	if b: return 1
	else: return -1

# flip image vertically if upside down
# @return whether to flip image
func check_flip(angle : float) -> bool: 
	var check_angle =  normal(angle)
	
	if check_angle >= (PI/2) and check_angle < (PI*3/2):
		return true
	else:
		return false

# returns random value from given list
# @pre list is NOT empty
func choose(list): 
	return list[random(len(list) - 1)]

func db(percentage : float) -> float: # returns decibel value of given percentage
	return 20 * (log(percentage) / log(10))

func get_position_centered(position : Vector2, size : Vector2) -> Vector2: # calculates the position as centered around a given point
	return position - size / 2

# returns the maximum value from a given list
# NOTE: only positive numbers will be considered
func max_list(list):
	var max_value = 0
	for i in list:
		if i > max_value: max_value = i
	return max_value

func normal(angle : float) -> float:
	var check_angle = angle
	while (check_angle > (2*PI)): check_angle -= (2*PI)
	while (check_angle < 0): check_angle += (2*PI)
	return check_angle

func random(n : int) -> int: # returns an integer between 0 and n, inclusive
	return randi() % (n + 1)

func randomf(n : float) -> float: # returns a float between 0 and n, inclusive
	return randf() * n