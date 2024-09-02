extends Marker3D

var CAMERA_SPEED = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO maybe fix this :
	# code line removed because the current code is not robust to this initial rotation for some reason
#	$Camera.transform = $Camera.transform.looking_at(self.transform.origin, Vector3.UP)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# movement
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		var strafe = CAMERA_SPEED * self.transform.basis.x
		strafe.y = 0
		self.transform.origin += strafe
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_Q):
		var strafe = - CAMERA_SPEED * self.transform.basis.x
		strafe.y = 0
		self.transform.origin += strafe
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_Z):
		var strafe = - CAMERA_SPEED * self.transform.basis.z
		strafe.y = 0
		self.transform.origin += strafe
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		var strafe = CAMERA_SPEED * self.transform.basis.z
		strafe.y = 0
		self.transform.origin += strafe
	# rotation
	if Input.is_key_pressed(KEY_A):
		var new_rotation = self.transform.basis.rotated(Vector3.UP, CAMERA_SPEED)
		self.transform.basis = new_rotation
	if Input.is_key_pressed(KEY_E):
		var new_rotation = self.transform.basis.rotated(Vector3.UP, - CAMERA_SPEED)
		self.transform.basis = new_rotation

func _input(event):
	# zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var strafe = - CAMERA_SPEED * $Camera.transform.basis.z
			$Camera.transform.origin += strafe
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var strafe = + CAMERA_SPEED * $Camera.transform.basis.z
			$Camera.transform.origin += strafe
	# TODO maybe change camera orientation when dragging with mouse_wheel
