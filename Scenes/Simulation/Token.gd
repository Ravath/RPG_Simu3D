extends Node3D

class_name Token

@export var displayed_name:String = "Character"
@export var size : Vector3 = Vector3(1,1,1)
@export var model3D:Mesh

@export var ObjectType = Enum.ObjectType.CHARACTER
# prevents movement across him for other token
@export var blocking = true

@export var system:String = "DD3.5"
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

func getPos2d() :
	return Vector2(position.x,position.y)

func is_in(coordinate2D : Vector2) :
	var position2d = getPos2d()
	# check if the token is present at the given coordinates
	if position2d == coordinate2D :
		return true
	if coordinate2D.x >= position2d.x and coordinate2D.y >= position2d.y \
	and coordinate2D.x <= position2d.x + size.x - 1 \
	and coordinate2D.y <= position2d.y + size.y - 1 :
		return true
	return false

func go_to(coord : nav_node) :
	position.x = coord.position.x
	position.y = coord.position.y
	moved_at.emit(coord)

func can_go(map, fs:Vector2, ts:Vector2):
	return movement.can_go(map, fs, ts)

func find_walkable(map):
	return movement.find_walkable(map, getPos2d(), get_move_points())

func get_actions():
	if sheet :
		var act = sheet.get_actions()
		for a in act :
			a.agent = self
		return act
	pass
