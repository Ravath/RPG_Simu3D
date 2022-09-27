extends GDScript

class_name Character

var position = Vector2() # grid position

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

func get_move_points():
	return 6

func get_name():
	return "Hero"

class nav_node :
	# A class used for pathfinding algorithms
	var position : Vector2
	var previous : Vector2
	var move_cost : float # total move cost from the path start
	func _init(from, to, cost):
		self.position = to
		self.previous = from
		self.move_cost = cost

func find_walkable(map):
	var to_search = [nav_node.new(position, position, 0)]
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
			var fastest = null
			for sn in walkable:
				if sn.position == n :
					fastest = sn
					break
			
			# if convenient, use it
			var total_cost = current.move_cost + cost
			if total_cost <= get_move_points() :
				if fastest and total_cost < fastest.move_cost :
					print("fastest way found, but not used")
				elif not fastest :
					# set walkable
					var w = nav_node.new(current.position, n, total_cost)
					to_search.append(w)
					walkable.append(w)

	return walkable
