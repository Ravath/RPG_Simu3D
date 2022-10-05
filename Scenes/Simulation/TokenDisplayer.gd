extends Spatial

# The tile dimensions
var W
var H
const C_H = 4 # Character height in multiple of H
#TODO Character Height is a room builder parameter

var map
var tokens : Array # token_model[]

# steps for moving a token sequentially during process
var steps = []	# each step : [ object, destination2D ]

# Called when the node enters the scene tree for the first time.
func _ready():
	W = get_parent().TILE_WIDTH
	H = get_parent().TILE_HEIGHT
	pass # Replace with function body.

func _process(_delta):
	if not $Tween.is_active() and steps.size() > 0 :
		var args = steps.pop_front()
		var mock_token = args[0].token
		mock_token.position = args[1]
		$Tween.interpolate_property(args[0].mesh, "transform",
			null, get_mesh_transform(mock_token), 0.1,
			Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
		$Tween.start()

func add_tokens(_map):
	# Set the map to use
	# Adds every token on the map for display
	self.map = _map
	tokens.clear()
	
	for new_token in map.tokens:
		# create a mesh displaying the token
		var m = MeshInstance.new()
		m.set_mesh(new_token.model3D)
		m.transform = get_mesh_transform(new_token)
		
		# connect for display update and save the references
		var tm = token_model.new(new_token, m, self)
		new_token.connect("moved_at", tm, "update_position")
		
		add_child(m)
		tokens.append(tm)

func get_mesh_transform(token : Token) :
	# Convert the token position and size into a display Transform
	var position = Transform()
	var alt = map.get_height(token.position)
	position = position.translated(Vector3(
		# Since the origin of the mesh is at the center, add an offest for the size rescaling
		token.position.x * W + (token.size.x-1) * W / 2 ,
		(alt+0.5)*H + (C_H * H * token.size.z / 2), # assumes the origines of tiles and character meshes are at the center
		token.position.y * W + (token.size.y-1) * W / 2 ))
	var scale = Transform()
	scale = scale.scaled(Vector3(token.size.x,token.size.z, token.size.y))
	return position * scale

func update_tokens_at(coordinate2D):
	for tm in tokens:
		if tm.token.is_in(coordinate2D):
			self.steps.append([tm,coordinate2D])

class token_model:
	# Custom data for managing the tokens to display
	var token : Token	# Token to display
	var mesh : MeshInstance # Mesh instance of the token
	var displayer # The parent TokenDisplayer
	
	func _init(_token, _mesh, _displayer):
		self.token = _token
		self.mesh = _mesh
		self.displayer = _displayer
	
	func update_position(coord : nav_node):
		# Schedule the movement tile by tile
		var steps = []
		var node = coord
		while node:
			var args = [self, node.position]
			steps.push_front(args)
			node = node.previous
		for s in steps:
			displayer.steps.append(s)
