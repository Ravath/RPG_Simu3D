extends MultiMeshInstance


# The tile dimensions
const W = 2
const H = 0.5
# over-elevation for not placing the highlight in the tile
const epsilon = 0.001

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_highlight(map, zone):
	
	if zone == null:
		self.multimesh.instance_count = 0
		return
	
	# instantiate and positionate the highlight
	self.multimesh.instance_count = zone.size()
	
	for i in zone.size():
		var position = Transform()
		var alt = map.get_height(zone[i])
		position = position.translated(Vector3(zone[i].x * W, (alt+0.5)*H + epsilon, zone[i].y * W))
		self.multimesh.set_instance_transform(i, position)
