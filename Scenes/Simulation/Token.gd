extends Spatial

class_name Token

export(String) var displayed_name = "Character"
export var position : Vector2
export var size : Vector3 = Vector3(1,1,1)
export(Mesh) var model3D

export(int, "FLOOR", "OBJECT", "CHARACTER") \
	var ObjectType = Enum.ObjectType.CHARACTER # ObjectType
# prevents movement across him for other token
export(bool) var blocking = true

export(String, "DD3.5") var system
var character # Character Sheet
var movement = WalkStrategy.new()
var sheet = null

signal moved_at(nav_end) # nav_end : nav_node of the track, starting at the end

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("WalkStrategy") :
		movement = $WalkStrategy
	if has_node("CharacterSheet") :
		sheet = $CharacterSheet
	pass # Replace with function body.

func get_move_points():
	if not sheet:
		return 0
	return sheet.get_move_points()

func is_in(coordinate2D : Vector2) :
	# check if the token is present at the given coordinates
	if position == coordinate2D :
		return true
	if coordinate2D.x >= position.x and coordinate2D.y >= position.y \
	and coordinate2D.x <= position.x + size.x - 1 \
	and coordinate2D.y <= position.y + size.y - 1 :
		return true
	return false

func go_to(coord : nav_node) :
	position = coord.position
	emit_signal("moved_at", coord)

func can_go(map, fs:Vector2, ts:Vector2):
	return movement.can_go(map, fs, ts)

func find_walkable(map):
	return movement.find_walkable(map, position, get_move_points())

func get_actions():
	if sheet :
		var act = sheet.get_actions()
		for a in act :
			a.agent = self
		return act
	pass
