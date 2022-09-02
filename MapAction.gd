extends GDScript

class_name MapAction

class MapUp :
	func _init():
		pass
	func action(map, x, y):
		var alt = map.grid[x][y]
		map.set_height(x,y,alt+1)

class MapDown :
	func _init():
		pass
	func action(map, x, y):
		var alt = map.grid[x][y]
		map.set_height(x,y,alt-1)
