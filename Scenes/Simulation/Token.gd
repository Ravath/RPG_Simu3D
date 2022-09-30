extends Spatial

class_name Token

export(String) var displayed_name = "Character"
export var position : Vector2
export var size : Vector3 = Vector3(1,1,1)
export(Mesh) var model3D

# TODO change to a mean to differenciate characters, items, and such
export(bool) var can_walk = false

export(String, "DD3.5") var system
var character # Character Sheet

signal moved_at(nav_end) # nav_end : nav_node of the track, starting at the end

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_move_points():
	return 6

func is_in(coordinate2D : Vector2) :
	# check if the token is present at the given coordinates
	if position == coordinate2D :
		return true
	if coordinate2D.x >= position.x and coordinate2D.y >= position.y \
	and coordinate2D.x <= position.x + size.x - 1 \
	and coordinate2D.y <= position.y + size.y - 1 :
		return true
	return false

func go_to(coord : nav_node) :
	position = coord.position
	emit_signal("moved_at", coord)

func can_go(map, fs:Vector2, ts:Vector2):
#	map as MapData
# return move cost, -1 if impossible
	if ts.x < 0 or ts.y < 0 or ts.x >= map.X or ts.y >= map.Y:
		return -1
#	if fs.x < 0 or fs.y < 0 or fs.x >= map.X or fs.y >= map.Y:
#		return -1
	var fh = map.grid[fs.x][fs.y]
	var th = map.grid[ts.x][ts.y]
	# check if diagonal
	var diagonal = 1
	if fs.x != ts.x and fs.y != ts.y:
		diagonal = 1.5
	if abs(fh-th) < 2 :
		return 1 * diagonal
	elif abs(fh-th) < 4 :
		return 2 * diagonal
	return -1

func find_walkable(map):
	# Computes the walkable zone for this token
	var to_search = [nav_node.new(null, position, 0)]
	var walkable = [to_search[0]]
	var searched = []
#	var neighbours = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var neighbours = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
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
			if total_cost <= get_move_points() :
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
