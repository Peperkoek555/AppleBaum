extends Node

var increment : float
var is_periodic : bool
var limit : float
var limit_base : float
var limit_random : float
var time : float

# @return whether timer times out
func advance(delta : float) -> bool:
	return advance_thres(delta, [limit]) == 0

# @return whether time has been increased
# NOTE: redundant if 'is_periodic'
func advance_active(delta : float) -> bool:
	
	if !is_full():
		# warning-ignore:return_value_discarded
		inc_time(delta)
		return true
	return false

# @return
#	index of 'percentiles' which was passed by advancing
#	-1 if none
func advance_perc(delta : float, percentiles : Array) -> int:
	
	var thresholds = []
	for i in range(len(percentiles)):
		thresholds.append(percentiles[i] * limit)
	return advance_thres(delta, thresholds)

# @return
#	index of 'thresholds' which was passed by advancing
#	-1 if none
func advance_thres(delta : float, thresholds : Array) -> int:
	
	var time_old = time
	var time_new = inc_time(delta)
	
	for i in range(len(thresholds)):
		if time_old < thresholds[i] && time_new >= thresholds[i]:
			return i
	return -1

func alt_limit(relative_limit : float) -> void:
	
	limit += relative_limit
	time += relative_limit
	if limit < 0: limit = 0
	if time < 0: time = 0

func complete() -> void:
	time = limit

func get_progress(get_inverted : bool = false) -> float:
	return abs(int(get_inverted) - float(time) / limit)

# PRIVATE
# @return the new time (or limit if timer timed out)
func inc_time(delta : float) -> float:
	
	time += increment * delta
	if is_full() && is_periodic:
		
		time -= limit
		var limit_old = limit
		update_limit()
		return limit_old
	return time

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func init(limit : float, limit_random : float = 0.0, is_periodic : bool = true, \
	starts_full : bool = false, increment : float = 1.0) -> void:
	
	self.limit_base = limit
	self.limit_random = limit_random
	update_limit()
	self.is_periodic = is_periodic
	self.increment = increment
	self.time = 0 + int(starts_full) * limit

func is_full() -> bool:
	return time >= limit

func reset() -> void:
	time = 0

func update_limit() -> void:
	# warning-ignore:narrowing_conversion
	limit = limit_base + g.random(limit_random)
