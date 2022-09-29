extends MultiMeshInstance


# The tile dimensions
const W = 2
const H = 0.5
const epsilon = H/2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func draw_line(map, start_node) :
	# start_node is a nav_node
	
	if not start_node:
		
		self.multimesh.instance_count = 0
		return
	
	# count the number of tiles in length
	var count = 0
	var c = start_node
	while c :
		count += 1
		c = c.previous
		# TODO add 1 each time there is an elevation
	
	# instantiate and positionate the highlight
	self.multimesh.instance_count = count
	
	c = start_node
	count = 0
	while c :
		var rotation = Transform()
		var position = Transform()
		var alt = map.get_height(c.position)
		position.origin = Vector3(c.position.x * W, (alt+0.5)*H + epsilon, c.position.y * W)
#		position = position.translated(Vector3(c.position.x * W, (alt+0.5)*H + epsilon, c.position.y * W))
		
		# do rotation
		if c.previous :
			if c.position.x != c.previous.position.x :
				var angle = PI/2
				if c.position.y != c.previous.position.y :
					angle = -PI/4
				if c.position.y < c.previous.position.y and c.position.x < c.previous.position.x \
				or c.position.y > c.previous.position.y and c.position.x > c.previous.position.x :
					angle = - angle
				rotation = rotation.rotated(Vector3.UP , angle)
			
		self.multimesh.set_instance_transform(count, position*rotation)
		
		count += 1
		c = c.previous

