extends GDScript

class_name MapAction

class MapActionAbst:
	func left_click_action(map, coord2D:Vector2):
		pass
	func right_click_action(map, coord2D:Vector2):
		pass

class MapSculpt :
	extends MapActionAbst
	# Elevate tile height on left click, reduce it on right click
	func left_click_action(map, coord2D:Vector2):
		var alt = map.grid[coord2D.x][coord2D.y]
		map.set_height(coord2D.x,coord2D.y,alt+1)
	func right_click_action(map, coord2D:Vector2):
		var alt = map.grid[coord2D.x][coord2D.y]
		map.set_height(coord2D.x,coord2D.y,alt-1)

