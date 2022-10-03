extends Node

class_name DD3_CharacterSheet

var For = 10
var Dex = 10
var Con = 10
var Int = 10
var Sag = 10
var Cha = 10

var health_points = 10
var armor_class = 10

var actions = []

# Emited when health reaches death, prone or max thresholds
signal health_at(charactersheet)

class Action:
	var agent : Token
	var name : String
	var target_type
	var distance
	var do_function

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()	
	var att = Action.new()
	att.name = "Attack"
	att.target_type = "Character"
	att.distance = 1.5
	att.do_function = funcref(self, "attack")
	actions.append(att)
	pass # Replace with function body.

func get_actions():
	return actions

func attack(target : DD3_CharacterSheet):
	var att = randi()%20+1
	if att >= target.armor_class :
		var damage = randi()%8+1
		target.loose_health(damage)
	pass

func loose_health(damage:int):
	if health_points > 0 and damage > health_points:
		health_points -= damage
		print(health_points)
		emit_signal("health_at", self)
