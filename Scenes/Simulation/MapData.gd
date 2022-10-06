extends Node

export var X:int = 10
export var Y:int = 10
export var MAX_ALTITUDE:int  = 5
# the generation methode at initialisation
export(String, "None", \
	"builder_room", "builder_ruins", \
	"builder_flatrand", "builder_dicerand", \
	"builder_exporand", "builder_gradiant") var generation = "builder_ruins"

var grid = [] # int[][] -> elevation
var tokens = [] # Token List

signal updated_tile_height(coordinate2D)
var update = false
var updated_tiles = []

func _ready():
	randomize()
	init_grid(X,Y)
	# Generate some elevation using the given generation function
	if generation and generation != "None" :
		build_grid(funcref(self, generation))
	
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
	emit_signal("updated_tile_height", Vector2(x,y))
	update = true
	updated_tiles.append(Vector2(x,y))

func get_height(var pos):
	return grid[pos.x][pos.y]

func contains(coord2D):
	return coord2D.x>=0 and coord2D.y>=0 \
		and coord2D.x <X and coord2D.y <Y

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

func builder_flatrand(_x:int, _y:int):
	return randi() % MAX_ALTITUDE

func builder_dicerand(_x:int, _y:int):
	var alt = (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE) + (randi() % MAX_ALTITUDE)
	return alt / 3

func builder_exporand(_x:int, _y:int):
	var alt = randi() % MAX_ALTITUDE
	return alt * alt / MAX_ALTITUDE
#	var alt = randi() % int(round(sqrt(MAX_ALTITUDE)))
#	return int(alt * alt)

func builder_gradiant(x:int, y:int):
	return int(float(x+y) / 2 / max(X,Y) * MAX_ALTITUDE)

func add_token(nt : Token) :
	tokens.append(nt)

func get_tokens_at(coord2D):
	var items = []
	for c in tokens:
		if c.is_in(coord2D):
			items.append(c)
	return items

func get_blockables_at(coord2D):
	var items = []
	for c in tokens:
		if c.is_in(coord2D) and c.blocking:
			items.append(c)
	return items
		
