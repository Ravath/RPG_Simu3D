extends MultiMeshInstance3D
# A 3D model of a map

var TILE_WIDTH
var TILE_HEIGHT
var click_managers = []	# the list of tile click detectors (one per tile)

signal mouse_tile_event(event, coordinate2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	TILE_WIDTH = get_parent().TILE_WIDTH
	TILE_HEIGHT = get_parent().TILE_HEIGHT
	
func update_grid(map):
	# instantiate and positionate the tiles
	self.multimesh.instance_count = map.X * map.Y * map.MAX_ALTITUDE

	for x in range(map.X):
		for y in range(map.Y):
			# place every tiles
			for z in range(map.grid[x][y] + 1):
				var translation = Transform3D()
				translation = translation.translated(Vector3(TILE_WIDTH*x, TILE_HEIGHT*z, TILE_WIDTH*y))
				self.multimesh.set_instance_transform(x*map.MAX_ALTITUDE*map.Y + y*map.MAX_ALTITUDE + z, translation)
			# place the click management
			var col = $Click_detection.duplicate()
			col.visible = true
			col.name = col.name + "_" + str(self.click_managers.size())
			self.click_managers.append(col)
			update_click_manager_at(map, x, y, map.grid[x][y])
			self.add_child(col)

func update_tile_at(map, coordinate2D):
	var v = coordinate2D as Vector2
	# place tiles
	for i in range(map.MAX_ALTITUDE):
		var translation = Transform3D()
		if i <= map.grid[v.x][v.y]:
			translation = translation.translated(Vector3(TILE_WIDTH*v.x, TILE_HEIGHT*i, TILE_WIDTH*v.y))
		self.multimesh.set_instance_transform(v.x*map.MAX_ALTITUDE*map.Y + v.y*map.MAX_ALTITUDE + i, translation)
	# update click_manager
	update_click_manager_at(map, v.x, v.y, map.grid[v.x][v.y])
	
func update_click_manager_at(map, x, y, z):
	# update the CollisionShape height and position used to detect clicks at the given coordinates
	var col = self.click_managers[x * map.Y + y]
	col.transform.origin.x = TILE_WIDTH * x
	col.transform.origin.z = TILE_WIDTH * y
	col.transform.origin.y = TILE_HEIGHT * z /2
	col.scale.y = 1.0 * (z+1)

func _on_Area_input_event(_camera, event, click_position, click_normal, _shape_idx):
	# when a tile is clicked_on, deduce the grid coordinates
	# then execute the current tool and selection process
	var gp = pos_to_grid(click_position - 0.05 * click_normal)
	mouse_tile_event.emit(event, gp)

func pos_to_grid(global_position2d) :
	# convert a global position2D into a grid coordinate2D
	# This is an old (and probably wrong) formula with the scale taken into account, in case of future need
#	var x = (((global_position.x - self.transform.origin.x) / self.scale.x) + TILE_WIDTH/2) / TILE_WIDTH
#	var y = (((global_position.z - self.transform.origin.z) / self.scale.z) + TILE_WIDTH/2) / TILE_WIDTH
	var x = ((global_position2d.x - self.transform.origin.x) + TILE_WIDTH/2) / TILE_WIDTH
	var y = ((global_position2d.z - self.transform.origin.z) + TILE_WIDTH/2) / TILE_WIDTH
	return Vector2(int(x),int(y))

func grid_to_pos(coordinate):
	# convert a grid coordinate2D into a global position2D
	return Vector2(
		coordinate.x * TILE_WIDTH  + self.transform.origin.x,
		coordinate.y * TILE_WIDTH  + self.transform.origin.y)
	# This is previous formula with scale and Height, in case of future need
#	return Vector2(
#		coordinate.x * TILE_WIDTH  * self.scale.x + self.transform.origin.x,
#		map.grid[coordinate.x][coordinate.y] * TILE_HEIGHT * self.scale.z + self.transform.origin.z,
#		coordinate.y * TILE_WIDTH  * self.scale.y + self.transform.origin.y)
