extends MultiMeshInstance


# The tile dimensions
var W
var H
const C_H = 2 # Character height


# Called when the node enters the scene tree for the first time.
func _ready():
	W = get_parent().TILE_WIDTH
	H = get_parent().TILE_HEIGHT
	pass # Replace with function body.

func update_characters(var map):
	
	if map == null:
		self.multimesh.instance_count = 0
		return
	
	# instantiate and positionate the highlight
	self.multimesh.instance_count = map.characters.size()
	
	for i in map.characters.size():
		var ci = map.characters[i]
		var position = Transform()
		var alt = map.get_height(ci.position)
		position = position.translated(Vector3(ci.position.x * W, (alt+0.5)*H+C_H/2, ci.position.y * W))
		self.multimesh.set_instance_transform(i, position)

