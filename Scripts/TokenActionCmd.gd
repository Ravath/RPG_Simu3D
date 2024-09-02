extends ActionCommand.ActionCommandAbst

class_name TokenActionCmd

class Action:
	var agent : Token
	var name : String
	var target_type : int # Enum.ObjectType
	var distance : float
	var do_function # reference to a function

var gc
var action
var found_target

func _init(gamecontroller, token_action):
	gc = gamecontroller
	action = token_action

func left_click_action(_coord2D:Vector2):
	if found_target:
		action.do_function.call_func(found_target)

func enters_tile_action(coord2D:Vector2):
	found_target = null
	for token in gc.map.get_tokens_at(coord2D) :
		if token.ObjectType == action.target_type :
			found_target = token
	
	if found_target :
		gc.get_display().highlight_zone([coord2D], Color.GREEN)
	else:
		gc.get_display().highlight_zone([coord2D], Color.GREEN)
	
	
func on_remove():
	pass
