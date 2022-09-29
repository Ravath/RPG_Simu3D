extends Spatial


const TILE_WIDTH = 2	# size of a 3D model tile
const TILE_HEIGHT = 0.5	# height of a 3D model tile

var map	# the map to display

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_map(new_map):
	self.map = new_map #MapData
	$TileBuilder_Square.update_grid(map)
	$CharacterDisplayer.update_characters(map)

func update_tile_at(coordinate2D):
	$TileBuilder_Square.update_tile_at(map, coordinate2D)
	$CharacterDisplayer.update_characters(map)
	
func update_characters():
	$CharacterDisplayer.update_characters(map)

func set_selection_cursor(pos):
	$Selector.transform.origin = Vector3(
		pos.x * TILE_WIDTH ,
		map.grid[pos.x][pos.y] * TILE_HEIGHT,
		pos.y * TILE_WIDTH ) + Vector3.UP * 0.3

func highlight_zone(zone):
	# draw a highlighting for the given tiles
	# zone : Vector2[] of the tiles to highlight
	$ZoneHighlighter.set_highlight(map, zone)

func draw_line(start_node) :
	# draw a pathline starting from the given navigation node nav_node
	# zone : nav_node of the path to show
	$ArrowDrawer.draw_line(map, start_node)
