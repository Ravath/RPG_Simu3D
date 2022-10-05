extends Spatial

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)
var current_coordinate : Vector2 # last known Grid Coordinates of the mouse

# Called when the node enters the scene tree for the first time.
func _ready():
	map = $SceneData/MapData
	current_tool = SelectionCmd.new(self, map)

	# give map to display module
	get_display().set_map(map)
	map.connect("updated_tile_height", self, "_on_updated_tile_height")

func get_display():
	return $Display3D

func _on_updated_tile_height(coordinate2D):
	# when the map has been changed, update the 3D model
	get_display().update_tile_at(coordinate2D)

func Tile_Left_Click(coordinate2D):
	if current_tool:
		current_tool.left_click_action(coordinate2D)

func Tile_Right_Click(coordinate2D):
	if current_tool:
		current_tool.right_click_action(coordinate2D)
	
func Tile_Mouse_Enters(coordinate2D):
	if current_tool:
		current_tool.enters_tile_action(coordinate2D)
	$Coordinate.set_text(str(coordinate2D))

func _on_TileBuilder_Square_mouse_tile_event(event, coordinate2D):
	
	# Do mouse action on LEFT_CLICK
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed :
		Tile_Left_Click(coordinate2D)
		
	# Move the selected character on RIGHT_CLICK
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed :
		Tile_Right_Click(coordinate2D)
	
	# update the DisplayPanels with the tile info of the one under the mouse
	if current_coordinate != coordinate2D:
		current_coordinate = coordinate2D
		Tile_Mouse_Enters(coordinate2D)
	
	get_display().set_selection_cursor(coordinate2D)

func set_current_tool(new_tool):
	if current_tool:
		current_tool.on_remove()
	current_tool = new_tool

func _on_Button_select_pressed():
	set_current_tool(SelectionCmd.new(self, map))

func _on_Button_sculptTool_pressed():
	set_current_tool(ActionCommand.SculptCmd.new(map))

func _on_action_choosed(action):
	# TODO use command pattern when implemented
	print("Action selected : " + action.name)
	set_current_tool(TokenActionCmd.new(self, action))

