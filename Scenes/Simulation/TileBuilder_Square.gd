extends MultiMeshInstance
# A 3D model of a map

const TILE_WIDTH = 2	# size of a 3D model tile
const TILE_HEIGHT = 0.5	# height of a 3D model tile

var map	# the map to display
var click_managers = []	# the list of tile click detectors (one per tile)

signal tile_selected(coordinate2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_map(map):
	self.map = map #MapData
	update()
	
func update():
	# instantiate and positionate the tiles
	self.multimesh.instance_count = map.X * map.Y * map.MAX_ALTITUDE

	for x in range(map.X):
		for y in range(map.Y):
			# place every tiles
			for z in range(map.grid[x][y] + 1):
				var position = Transform()
				position = position.translated(Vector3(TILE_WIDTH*x, TILE_HEIGHT*z, TILE_WIDTH*y))
				self.multimesh.set_instance_transform(x*map.MAX_ALTITUDE*map.Y + y*map.MAX_ALTITUDE + z, position)
			# place the click management
			var col = $Click_detection.duplicate()
			col.visible = true
			col.name = col.name + "_" + str(self.click_managers.size())
			self.click_managers.append(col)
			update_click_manager_at(x, y, map.grid[x][y])
			self.add_child(col)

func update_tile_at(coordinate2D):
	var v = coordinate2D as Vector2
	# place tiles
	for i in range(map.MAX_ALTITUDE):
		var position = Transform()
		if i <= map.grid[v.x][v.y]:
			position = position.translated(Vector3(TILE_WIDTH*v.x, TILE_HEIGHT*i, TILE_WIDTH*v.y))
		self.multimesh.set_instance_transform(v.x*map.MAX_ALTITUDE*map.Y + v.y*map.MAX_ALTITUDE + i, position)
	# update click_manager
	update_click_manager_at(v.x, v.y, map.grid[v.x][v.y])

func update_click_manager_at(x, y, z):
	# update the CollisionShape height and position used to detect clicks at the given coordinates
	var col = self.click_managers[x * map.Y + y]
	col.transform.origin.x = TILE_WIDTH * x
	col.transform.origin.z = TILE_WIDTH * y
	col.transform.origin.y = TILE_HEIGHT * z /2
	col.scale.y = 1.0 * (z+1)

func _on_Area_input_event(_camera, event, click_position, click_normal, _shape_idx):
	# when a tile is clicked_on, deduce the grid coordinates
	# then execute the current tool and selection process
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed :
		var gp = pos_to_grid(click_position - 0.05 * click_normal)
		
		emit_signal("tile_selected", gp)
		
		set_selection_cursor(gp)

func pos_to_grid(position) :
	# convert a global position2D into a grid coordinate2D
	# TODO maybe simplify for optimisation if not using scaling on the map
	var x = (((position.x - self.transform.origin.x) / self.scale.x) + TILE_WIDTH/2) / TILE_WIDTH
	var y = (((position.z - self.transform.origin.z) / self.scale.z) + TILE_WIDTH/2) / TILE_WIDTH
	return Vector2(int(x),int(y))

func grid_to_pos(coordinate):
	# convert a grid coordinate2S into a global position3D
	return Vector3(
		coordinate.x * TILE_WIDTH  * self.scale.x + self.transform.origin.x,
		map.grid[coordinate.x][coordinate.y] * TILE_HEIGHT * self.scale.z + self.transform.origin.z,
		coordinate.y * TILE_WIDTH  * self.scale.y + self.transform.origin.y)

func to_center_tile():
	# Get the offset from the corner to the center of a tile
	return Vector3(
		TILE_WIDTH/2  * self.scale.x,
		TILE_HEIGHT/2 * self.scale.y,
		TILE_WIDTH/2  * self.scale.z)

func set_selection_cursor(pos):
	$Selector.transform.origin = Vector3(
		pos.x * TILE_WIDTH ,
		map.grid[pos.x][pos.y] * TILE_HEIGHT,
		pos.y * TILE_WIDTH ) + Vector3.UP * 0.3

func highlight_zone(zone):
	# draw a highlighting for the given tiles
	# zone : Vector2[] of the tiles to highlight
	$ZoneHighlighter.set_highlight(map, zone)
