extends Node

var _config_file = ConfigFile.new()
var distance_best : int = 0

const SAVE_PATH = "res://config.cfg"

func load_settings() -> void:
	
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print("Failed loading settings file. Error code %s"% error)
	
	distance_best = _config_file.get_value("distance_best", "distance_best",  distance_best)

func save_settings() -> void:
	
	_config_file.set_value("distance_best", "distance_best", distance_best)
	_config_file.save(SAVE_PATH)

#---------------------------GENERAL-FUNCTION-LIBRARY-------------------------------#

# returns -1 for false; 1 for true
func bool2sign(b : bool) -> int:
	
	if b: return 1
	else: return -1

# returns true with a chance of 1 / n
func chance(n : int) -> bool:
	return random(n - 1) == 0

# returns random value from given list
# @pre 'list' is NOT empty
func choose(list : Array): 
	return list[random(len(list)) - 1]

# returns a random index number from 'weights', where
# 	| higher weight -> higher chance to be picked
# @pre 'weights' is NOT empty
func choose_weighted(weights : Array) -> int:
	
	var x = random(sum(weights) - 1)
	var cumsum = 0
	for i in weights:
		cumsum += i
		if x < cumsum:
			return weights.find(i)
	return -1

# returns decibel value of given percentage, relative to a given 'full' (db)
func db(percentage : float, full_volume : float) -> float: 
	return -20 + (full_volume + 20) * percentage

# returns the maximum value from a given list
# NOTE: only positive numbers will be considered
func max_list(list):
	
	var max_value = 0
	for i in list:
		if i > max_value: max_value = i
	return max_value

# returns 'value' if value is between [low, high]
# returns 'low' if value < low
# returns 'high' if value > high
func normal(value : float, low : float, high : float) -> float:
	
	if value < low: return low
	if value > high: return high
	return value

# returns an integer between [0, n]
func random(n : int) -> int:
	return randi() % (n + 1)

# returns a float between [0, n]
func randomf(n : float) -> float: 
	return randf() * n

# returns the sum of all elements from the given list
# @pre 'list' only contains integer values
func sum(list : Array) -> int:
	
	var sum = 0
	for i in list:
		sum += i
	return sum
