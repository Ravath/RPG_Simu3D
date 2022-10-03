extends Button


var action # Action
signal on_action_choosed(action)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Template_pressed():
	emit_signal("on_action_choosed", action)

