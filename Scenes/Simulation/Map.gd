extends Spatial

var map	# the map to display
var current_tool = null	# current tool used on click (null for selection only)

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
	var selected_character = null
	
	# selection process
	var display = "Height : "
	display = display + str(map.get_height(coordinate))
	var misc = map.get_selected_items(coordinate)
	for item in misc :
		if item is Character:
			display = display + "\nCharacter : " + item.get_name()
			selected_character = item
		else :
			print(str(misc))
	$Panel/Label.set_text(display)
	
	# Tool process
	if current_tool:
		current_tool.action(map, coordinate.x, coordinate.y)
	
	# update walkable zone of selected character
	if selected_character:
		var walkable = selected_character.find_walkable(map)
		var zone = []
		for wz in walkable:
			zone.append(wz.position)
		$TileBuilder_Square.highlight_zone(zone)
	else :
		$TileBuilder_Square.highlight_zone(null)

func _on_Button_select_pressed():
	current_tool = null

func _on_Button_upTool_pressed():
	current_tool = MapAction.MapUp.new()

func _on_Button_downTool_pressed():
	current_tool = MapAction.MapDown.new()
