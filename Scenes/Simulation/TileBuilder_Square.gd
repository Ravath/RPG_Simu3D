extends MultiMeshInstance
# A 3D model of a map

const TILE_WIDTH = 2	# size of a 3D model tile
const TILE_HEIGHT = 0.5	# height of a 3D model tile

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)
var click_managers = []	# the list of tile click detectors (one per tile)

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO this is debug
	map = MapData.new(10,10,4)
#	map.build_grid(funcref(map, "builder_room"))
	map.build_grid(funcref(map, "builder_ruins"))
#	map.build_grid(funcref(map, "builder_flatrand"))
#	map.build_grid(funcref(map, "builder_dicerand"))
#	map.build_grid(funcref(map, "builder_exporand"))
#	map.build_grid(funcref(map, "builder_gradiant"))

	update()

func _process(_delta):
	# when the map has been changed, update the 3D model
	if map.update:
		for v in map.updated_tiles :
			# place tiles
			for i in range(map.MAX_ALTITUDE):
				var position = Transform()
				if i <= map.grid[v.x][v.y]:
					position = position.translated(Vector3(TILE_WIDTH*v.x, TILE_HEIGHT*i, TILE_WIDTH*v.y))
				self.multimesh.set_instance_transform(v.x*map.MAX_ALTITUDE*map.Y + v.y*map.MAX_ALTITUDE + i, position)
			# update click_manager
			update_click_manager_at(v.x, v.y, map.grid[v.x][v.y])
		map.updated_tiles.clear()
		map.update = false

func update_click_manager_at(x, y, z):
	# update the click on tile detector in size and position
	var col = self.click_managers[x * map.Y + y]
	col.transform.origin.x = TILE_WIDTH * x
	col.transform.origin.z = TILE_WIDTH * y
	col.transform.origin.y = TILE_HEIGHT * z /2
	col.scale.y = 1.0 * (z+1)

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

func _on_Area_input_event(_camera, event, click_position, click_normal, _shape_idx):
	# when a tile is clicked_on, deduce the grid coordinates
	# then execute the current tool and selection process
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed :
		var gp = pos_to_grid(click_position - 0.05 * click_normal)
		if current_tool:
			current_tool.action(map, gp.x, gp.y)
		$Selector.transform.origin = Vector3(
			gp.x * TILE_WIDTH ,
			map.grid[gp.x][gp.y] * TILE_HEIGHT,
			gp.y * TILE_WIDTH ) + Vector3.UP * 0.3
			
	pass

func pos_to_grid(position) :
	# convert a global position into a grid coordinate
	# TODO maybe simplify for optimisation if not using scaling on the map
	var x = (((position.x - self.transform.origin.x) / self.scale.x) + TILE_WIDTH/2) / TILE_WIDTH
	var y = (((position.z - self.transform.origin.z) / self.scale.z) + TILE_WIDTH/2) / TILE_WIDTH
	return Vector3(int(x),int(y),map.grid[x][y])

func grid_to_pos(coordinate):
	# convert a grid coordinate into a global position
	return Vector3(
		coordinate.x * TILE_WIDTH  * self.scale.x + self.transform.origin.x,
		coordinate.z * TILE_HEIGHT * self.scale.z + self.transform.origin.z,
		coordinate.y * TILE_WIDTH  * self.scale.y + self.transform.origin.y)

func to_center_tile():
	# Get the offset from the corner to the center of a tile
	return Vector3(
		TILE_WIDTH/2  * self.scale.x,
		TILE_HEIGHT/2 * self.scale.y,
		TILE_WIDTH/2  * self.scale.z)
