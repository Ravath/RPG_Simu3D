extends Node

class_name WalkStrategy

# Manhattan neighbours don't include diagonals
export(bool) var manhattan = false
# Cost factor  of moving diagonaly (if not Manhattan)
export(float) var diagonal_cost = 1.5
export(Array) var elevation_cost = [[2,1], [4,2]]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func can_go(map, fs:Vector2, ts:Vector2):
#	map as MapData
#	return move cost, -1 if impossible

	# Check map boundaries
	if ts.x < 0 or ts.y < 0 or ts.x >= map.X or ts.y >= map.Y:
		return -1

	# Check for blockable items
	var blockables = map.get_blockables_at(ts)
	if blockables.size() > 0 :
		return -1

	# check if diagonal
	var diagonal = 1
	if fs.x != ts.x and fs.y != ts.y:
		diagonal = diagonal_cost

	# Check elevation
	var h = abs(map.grid[fs.x][fs.y] - map.grid[ts.x][ts.y])
	var height_factor = -1
	for ec in elevation_cost:
		if h < ec[0]:
			height_factor = ec[1]
			break
	if height_factor == -1:
		return -1
	return diagonal * height_factor

func find_walkable(map, origin:Vector2, move_points:int):
	# Computes the walkable zone for this token
	var to_search = [nav_node.new(null, origin, 0)]
	var walkable = [to_search[0]]
	var neighbours = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	if not manhattan :
		neighbours = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
		Vector2.UP+Vector2.LEFT, Vector2.UP+Vector2.RIGHT,
		Vector2.DOWN+Vector2.LEFT, Vector2.DOWN+Vector2.RIGHT]
	
	while(to_search.size() > 0):
		var current = to_search.pop_front()
		
		# search every neighbours
		for dir in neighbours:
			var n = current.position + dir
			
			# find the cost
			var cost = can_go(map, current.position, n)
			if cost == -1 : # inaccessible
				continue
			
			# check if already searched
			var previous = null
			for sn in walkable:
				if sn.position == n :
					previous = sn
					break
			
			# if convenient, use it
			var total_cost = current.move_cost + cost
			if total_cost <= move_points :
				if previous and total_cost < previous.move_cost :
					# use the fastest
					previous.previous = current
					previous.position = n
					previous.move_cost = total_cost
				elif not previous :
					# set walkable
					var w = nav_node.new(current, n, total_cost)
					to_search.append(w)
					walkable.append(w)

	return walkable
