extends Spatial

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)
var selected_character = null # the currently selected Character
var walkable # walkable zone of the selected character
var current_coordinate : Vector2 # last known Grid Coordinates of the mouse

# Called when the node enters the scene tree for the first time.
func _ready():
	map = $SceneData/MapData

	# give map to display module
	$Display3D.set_map(map)
	map.connect("updated_tile_height", self, "_on_updated_tile_height")

func _on_updated_tile_height(coordinate2D):
	# when the map has been changed, update the 3D model
	$Display3D.update_tile_at(coordinate2D)

func Tile_Left_Click(coordinate2D):
	# selection process
	
	# Display tile information
	var display = "Height : "
	display = display + str(map.get_height(coordinate2D))
	var misc = map.get_tokens_at(coordinate2D)
	var found_character
	for token in misc :
		display = display + "\n" + token.displayed_name
		if token.can_walk :
			found_character = token
	selected_character = found_character
	$TileInfo/Label.set_text(display)
	
	# Display found token actions
	if selected_character :
		$TileInfo.set_actions(selected_character)
	
	# Tool process
	if current_tool:
		current_tool.left_click_action(map, coordinate2D)
	
	# update walkable zone of selected character
	if selected_character:
		update_walkable_zone(selected_character)
	else :
		$Display3D.highlight_zone(null)
		$Display3D.draw_line(null)

func Tile_Right_Click(coordinate2D):
	if selected_character and walkable :
		# find navigation node and go if any
		var end_node = find_nav_node(coordinate2D)
		if end_node:
			selected_character.go_to(end_node)
			# redo the selection stuff
			Tile_Left_Click(coordinate2D)
#			update_walkable_zone(selected_character)
			$Display3D.set_selection_cursor(coordinate2D)

	# Tool process
	if current_tool:
		current_tool.right_click_action(map, coordinate2D)
	
func Tile_Mouse_Enters(coordinate2D):
	$Coordinate.set_text(str(coordinate2D))
	
	# if a character is selected, display the path up to the current tile
	if selected_character and walkable :
		var end_node = find_nav_node(coordinate2D)
		if end_node:
			$Display3D.draw_line(end_node)
	
func update_walkable_zone(character) :
	walkable = character.find_walkable(map)
	var zone = []
	for node in walkable:
		zone.append(node.position)
	$Display3D.highlight_zone(zone)
	
func find_nav_node(coordinate2D):
	# Find the nav_node in the walkable zone that arrives at the given coordinates
	var end_node
	for n in walkable :
		if n.position == coordinate2D :
			end_node = n
			break
	return end_node

func _on_TileBuilder_Square_mouse_tile_event(event, coordinate2D):
	
	# Do mouse action on LEFT_CLICK
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed :
		
		Tile_Left_Click(coordinate2D)
		$Display3D.set_selection_cursor(coordinate2D)
		
	# Move the selected character on RIGHT_CLICK
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed :
		
		Tile_Right_Click(coordinate2D)
	
	# update the DisplayPanels with the tile info of the one under the mouse
	if current_coordinate != coordinate2D:
		current_coordinate = coordinate2D
		
		Tile_Mouse_Enters(coordinate2D)

func _on_Button_select_pressed():
	current_tool = null

func _on_Button_sculptTool_pressed():
	current_tool = MapAction.MapSculpt.new()

func _on_action_choosed(action):
	# TODO use command pattern when implemented
	print("Action selected : " + action.name)

