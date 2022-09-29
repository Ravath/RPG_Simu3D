extends Node


class_name nav_node

# A class used for pathfinding algorithms
var position : Vector2
var previous : nav_node
var move_cost : float # total move cost from the path start
func _init(from, to, cost):
	if from :
		self.previous = from
	self.position = to
	self.move_cost = cost
