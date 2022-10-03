extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_actions(token:Token):
	var actions = token.get_actions()
	
	# clean previous actions
	for child in $ActionButtons.get_children():
		if child != $ActionButtons/Template:
			child.queue_free()
	# dsplay action buttons
	if actions:
		for act in actions:
			var but = $ActionButtons/Template.duplicate()
			but.visible = true
			but.set_text(act.name)
			but.action = act
			$ActionButtons.add_child(but)
