extends ActionCommand.ActionCommandAbst

class_name SelectionCmd

var gc # The GameController
var map # The MapData
var selected_character = null # the currently selected Character
var walkable # walkable zone of the selected character

func _init(gamecontrol, new_map):
	self.gc = gamecontrol
	self.map = new_map

func left_click_action(coord2D:Vector2):
	# Display tile information
	var display = "Height : "
	display = display + str(map.get_height(coord2D))
	var found_character
	for token in map.get_tokens_at(coord2D) :
		display = display + "\n" + token.displayed_name
		if token.ObjectType == Enum.ObjectType.CHARACTER :
			found_character = token
	gc.get_node("TileInfo/Label").set_text(display)
	
	# Manage characte selection
	selected_character = found_character
	update_display()

func right_click_action(coord2D:Vector2):
	if selected_character and walkable :
		# find navigation node and go if any
		var end_node = find_nav_node(coord2D)
		if end_node:
			selected_character.go_to(end_node)
		update_display()

func enters_tile_action(coord2D:Vector2):
	# if a character is selected, display the path up to the current tile
	if selected_character and walkable :
		var end_node = find_nav_node(coord2D)
		if end_node:
			gc.get_display().draw_line(end_node)

func on_remove():
	selected_character = null
	update_display()

func update_walkable_zone(map) :
	walkable = selected_character.find_walkable(map)
	var zone = []
	for node in walkable:
		zone.append(node.position)
	gc.get_display().highlight_zone(zone)

func find_nav_node(coordinate2D):
	# Find the nav_node in the walkable zone that arrives at the given coordinates
	var end_node
	for n in walkable :
		if n.position == coordinate2D :
			end_node = n
			break
	return end_node
	
func update_display():
	if selected_character :
		# Display found token actions
		gc.get_node("TileInfo").set_actions(selected_character)
		# update walkable zone of selected character
		update_walkable_zone(map)
		gc.get_display().draw_line(null)
	else :
		gc.get_display().highlight_zone(null)
		gc.get_display().draw_line(null)
