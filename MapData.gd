extends GDScript

class_name MapData

var X:int
var Y:int
var MAX_ALTITUDE:int # MAX_ALTITUDE
var grid = []

var update = false
var updated_tiles = []

func _init(x,y,z):
	randomize()
	self.X = x
	self.Y = y
	self.MAX_ALTITUDE = z
	init_grid()

func init_grid():
	# init the 2D array, all altitudes at 0
	self.grid = []
	for x in range(X):
		grid.append([])
		grid[x] = []
		for y in range(Y):
			grid[x].append([])
			grid[x][y] = 0

func set_height(x,y,new_alt):
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

func builder_ruins(x,y):
	if x == 0 or x == X-1 or y == 0 or y == Y-1:
		return randi() % MAX_ALTITUDE
	return 0

func builder_room(x,y):
	if x == 0 or x == X-1 or y == 0 or y == Y-1:
		return MAX_ALTITUDE
	return 0

func builder_flatrand(_x,_y):
	return randi() % MAX_ALTITUDE

func builder_dicerand(_x,_y):
	var alt = (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE)
	return alt / 3

func builder_exporand(_x,_y):
	var alt = randi() % MAX_ALTITUDE
	return alt * alt / MAX_ALTITUDE
#	var alt = randi() % int(round(sqrt(MAX_ALTITUDE)))
#	return int(alt * alt)

func builder_gradiant(x,y):
	return int(float(x+y) / 2 / max(X,Y) * MAX_ALTITUDE)
