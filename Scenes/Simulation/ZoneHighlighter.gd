extends MultiMeshInstance3D


# The tile dimensions
var W 
var H
# over-elevation for not placing the highlight in the tile
const epsilon = 0.001

# Called when the node enters the scene tree for the first time.
func _ready():
	W = get_parent().TILE_WIDTH
	H = get_parent().TILE_HEIGHT
	pass

func set_highlight(map, zone, color:Color = Color(0x92be6332)):
	
	if zone == null:
		self.multimesh.instance_count = 0
		return
	
	# instantiate and positionate the highlight
	self.multimesh.instance_count = zone.size()
	
	for i in zone.size():
		var highlight_position = Transform3D()
		var alt = map.get_height(zone[i])
		highlight_position = highlight_position.translated(Vector3(zone[i].x * W, (alt+0.5)*H + epsilon, zone[i].y * W))
		self.multimesh.set_instance_transform(i, highlight_position)
		self.multimesh.set_instance_color(i, color)
