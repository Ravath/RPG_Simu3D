extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Button_select_pressed():
	$TileBuilder_Square.current_tool = null

func _on_Button_upTool_pressed():
	$TileBuilder_Square.current_tool = MapAction.MapUp.new()

func _on_Button_downTool_pressed():
	$TileBuilder_Square.current_tool = MapAction.MapDown.new()
