extends GDScript

class_name MapData

var X:int
var Y:int
var MAX_ALTITUDE:int # MAX_ALTITUDE
var grid = [] # int[][]

var update = false
var updated_tiles = []

func _init(x,y,z):
	randomize()
	init_grid(x,y)
	self.MAX_ALTITUDE = z

func init_grid(size_x:int, size_y:int):
	self.X = size_x
	self.Y = size_y
	# init the 2D array, all altitudes at 0
	self.grid = []
	self.grid.resize(X)
	for x in range(X):
		self.grid[x] = []
		self.grid[x].resize(Y)

func set_height(x:int, y:int, new_alt:int):
	# manage boundaries
	if new_alt >= MAX_ALTITUDE:
		new_alt = MAX_ALTITUDE-1
	elif new_alt < 0 :
		new_alt = 0
	if new_alt == grid[x][y] :
		return
	
	# update value and raise flag
	grid[x][y] = new_alt
	update = true
	updated_tiles.append(Vector2(x,y))

func build_grid(builder_function):
	# build a map with random altitudes
	for x in range(X):
		for y in range(Y):
			var alt = builder_function.call_func(x,y)
			grid[x][y] = alt

func builder_ruins(x:int, y:int):
	if x == 0 or x == X-1 or y == 0 or y == Y-1:
		return randi() % MAX_ALTITUDE
	return 0

func builder_room(x:int, y:int):
	if x == 0 or x == X-1 or y == 0 or y == Y-1:
		return MAX_ALTITUDE
	return 0

func builder_flatrand(x:int, y:int):
	return randi() % MAX_ALTITUDE

func builder_dicerand(x:int, y:int):
	var alt = (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE)
	return alt / 3

func builder_exporand(_x:int, _y:int):
	var alt = randi() % MAX_ALTITUDE
	return alt * alt / MAX_ALTITUDE
#	var alt = randi() % int(round(sqrt(MAX_ALTITUDE)))
#	return int(alt * alt)

func builder_gradiant(x:int, y:int):
	return int(float(x+y) / 2 / max(X,Y) * MAX_ALTITUDE)
