extends Node

var increment : float
var is_forced : bool
var is_periodic : bool
var limit : float
var time : float

# @return whether timer times out
func advance(delta : float, if_higher_than : float = 0) -> bool:
	return advanceThres(delta, limit, if_higher_than)

# @return whether timer is still running
func advanceActive(delta : float, if_higher_than : float = 0) -> bool:
	
	if time < if_higher_than: return false
	
	var is_active = !has_passed()
	advance(delta, if_higher_than)
	return is_active

# @return whether timer passes given threshold
# @param if_higher_than: advance time only if time >= if_higher_than
func advanceThres(delta : float, threshold : float, if_higher_than : float = 0) -> bool:
	
	if is_forced && threshold == limit: return true
	if threshold > limit: return false
	
	if has_passed(threshold): return false
	if time >= if_higher_than: time += increment * delta
	if has_passed(threshold): return true
	
	return false

func alt_limit(relative_limit : float) -> void:
	
	limit += relative_limit
	time += relative_limit
	if limit < 0: limit = 0
	if time < 0: time = 0

func complete() -> void:
	time = limit

func force() -> void:
	is_forced = true

func get_progress(get_inverted : bool = false) -> float:
	return abs(int(get_inverted) - float(time) / limit)

func has_passed(threshold : float = limit) -> bool:
	
	if time >= threshold:
		
		if threshold == limit && is_periodic:
			time -= limit
		return true
	
	return false

func init(limit : float, increment : float = 1.0, is_periodic = true, starts_full : bool = false) -> void:
	
	self.limit = limit
	self.increment = increment
	self.is_periodic = is_periodic
	self.time = 0 + int(starts_full) * limit
	self.is_forced = false

func reset() -> void:
	time = 0
