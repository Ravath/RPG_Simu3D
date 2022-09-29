extends Spatial

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)
var selected_character = null # the currently selected Character
var walkable # walkable zone of the selected character
var current_coordinate : Vector2 # last known Coordinate of the mouse

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO this is debug
	map = MapData.new(10,10,5)
#	map.build_grid(funcref(map, "builder_room"))
	map.build_grid(funcref(map, "builder_ruins"))
#	map.build_grid(funcref(map, "builder_flatrand"))
#	map.build_grid(funcref(map, "builder_dicerand"))
#	map.build_grid(funcref(map, "builder_exporand"))
#	map.build_grid(funcref(map, "builder_gradiant"))
	
	# add character
	var c1 = Character.new()
	var c2 = Character.new()
	c1.position = Vector2(1,1)
	c2.position = Vector2(6,8)
	map.add_character(c1)
	map.add_character(c2)

	# give map to display module
	$TileBuilder_Square.set_map(map)
	map.connect("updated_tile_height", self, "_on_updated_tile_height")

func _on_updated_tile_height(coordinate2D):
	# when the map has been changed, update the 3D model
	$TileBuilder_Square.update_tile_at(coordinate2D)

func _on_tile_selected(coordinate):
	
	# selection process
	var display = "Height : "
	display = display + str(map.get_height(coordinate))
	var misc = map.get_selected_items(coordinate)
	var found_character
	for item in misc :
		if item is Character:
			display = display + "\nCharacter : " + item.get_name()
			found_character = item
		else :
			print(str(misc))
	selected_character = found_character
	$Panel/Label.set_text(display)
	
	# Tool process
	if current_tool:
		current_tool.action(map, coordinate.x, coordinate.y)
	
	# update walkable zone of selected character
	if selected_character:
		update_walkable_zone(selected_character)
	else :
		$TileBuilder_Square.highlight_zone(null)
		$TileBuilder_Square.draw_line(null)

func update_walkable_zone(character) :
	walkable = character.find_walkable(map)
	var zone = []
	for wz in walkable:
		zone.append(wz.position)
	$TileBuilder_Square.highlight_zone(zone)
	
func find_nav_node(coordinate2D):
	# Find the nav_node in the walkable zone that arrives at the given coordinates
	var end_node
	for n in walkable :
		if n.position == coordinate2D :
			end_node = n
			break
	return end_node

func _on_TileBuilder_Square_mouse_tile_event(event, coordinate2D):
	
	#move the character on RIGHT_CLICK
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed \
	and selected_character and walkable :
		# find navigation node and go if any
		var end_node = find_nav_node(coordinate2D)
		if end_node:
			selected_character.position = end_node.position
			$TileBuilder_Square.update_characters()
			# redo the selection stuff
			_on_tile_selected(coordinate2D)
#			update_walkable_zone(selected_character)
			$TileBuilder_Square.set_selection_cursor(coordinate2D)
	
	# update the current tile under the mouse
	if current_coordinate != coordinate2D:
		current_coordinate = coordinate2D
		$Coordinate.set_text(str(coordinate2D))
		
		# if a character is selected, display the path up to the current tile
		if selected_character and walkable :
			var end_node = find_nav_node(coordinate2D)
			if end_node:
				$TileBuilder_Square.draw_line(end_node)

func _on_Button_select_pressed():
	current_tool = null

func _on_Button_upTool_pressed():
	current_tool = MapAction.MapUp.new()

func _on_Button_downTool_pressed():
	current_tool = MapAction.MapDown.new()

