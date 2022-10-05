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

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()	
	var att = TokenActionCmd.Action.new()
	att.name = "Attack"
	att.target_type = Enum.ObjectType.CHARACTER
	att.distance = 1.5
	att.do_function = funcref(self, "attack")
	actions.append(att)
	pass # Replace with function body.

func get_actions():
	return actions

func attack(token_target : Token):
	var target = token_target.sheet
	if not target :
		# TODO use debug log for warning
		print("warning : target has no charactersheet")
		return
	
	var log_text = ""
	var att = randi()%20+1
	log_text+= "(" + str(att) + ")"
	if att >= target.armor_class :
		var damage = randi()%8+1
		log_text += " hit! -> "+str(damage)
		print(log_text)
		target.loose_health(damage)
	else:
		log_text += " miss!"
		print(log_text)

enum health_state{dead, dying, sane}
func loose_health(damage:int):
	var state = health_state.sane
	if health_points > 0 and damage > health_points:
		state = health_state.dying
	health_points -= damage
	print(health_points)
	if state == health_state.dying :
		emit_signal("health_at", self)
