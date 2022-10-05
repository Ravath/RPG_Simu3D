extends GDScript

class_name ActionCommand

class ActionCommandAbst:
	func left_click_action(_coord2D:Vector2):
		pass
	func right_click_action(_coord2D:Vector2):
		pass
	func enters_tile_action(_coord2D:Vector2):
		pass
	func on_remove():
		pass

class SculptCmd :
	extends ActionCommandAbst
	var map

	func _init(new_map):
		self.map = new_map
	# Elevate tile height on left click, reduce it on right click
	func left_click_action(coord2D:Vector2):
		var alt = map.grid[coord2D.x][coord2D.y]
		map.set_height(coord2D.x,coord2D.y,alt+1)
	func right_click_action(coord2D:Vector2):
		var alt = map.grid[coord2D.x][coord2D.y]
		map.set_height(coord2D.x,coord2D.y,alt-1)
