extends Spatial

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)

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

	$TileBuilder_Square.set_map(map)
	map.connect("updated_tile_height", self, "_on_updated_tile_height")

func _on_updated_tile_height(coordinate2D):
	# when the map has been changed, update the 3D model
	$TileBuilder_Square.update_tile_at(coordinate2D)

func _on_tile_selected(coordinate):
	if current_tool:
		current_tool.action(map, coordinate.x, coordinate.y)

func _on_Button_select_pressed():
	current_tool = null

func _on_Button_upTool_pressed():
	current_tool = MapAction.MapUp.new()

func _on_Button_downTool_pressed():
	current_tool = MapAction.MapDown.new()
