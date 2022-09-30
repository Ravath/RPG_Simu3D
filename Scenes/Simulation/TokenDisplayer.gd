extends Spatial

# The tile dimensions
var W
var H
const C_H = 4 # Character height in multiple of H
#TODO Character Height is a room builder parameter

var tokens : Array # Token[]
var map

class token_model:
	var token : Token
	var mesh : MeshInstance
	var displayer
	
	func _init(token, mesh, displayer):
		self.token = token
		self.mesh = mesh
		self.displayer = displayer
	
	func update_position(coord : Vector2):
		var tw = displayer.get_node("Tween")
#		mesh.transform = displayer.get_mesh_transform(token)
		tw.interpolate_property(mesh, "transform",
			null, displayer.get_mesh_transform(token), 0.5,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tw.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	W = get_parent().TILE_WIDTH
	H = get_parent().TILE_HEIGHT
	pass # Replace with function body.


func add_tokens(map):
	self.map = map
	for new_token in map.tokens:
		var m = MeshInstance.new()
		m.set_mesh(new_token.model3D)
		m.transform = get_mesh_transform(new_token)
		
		var tm = token_model.new(new_token, m, self)
		new_token.connect("moved_at", tm, "update_position")
		
		add_child(m)
		tokens.append(tm)

func update_token(token):
	pass


func get_mesh_transform(token : Token) :
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
	
