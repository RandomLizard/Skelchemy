extends RigidBody2D

var mouseOver: bool = false
var isGrabbed: bool = false

var screenSpace
var mousePos
var spawnPos
var defaultDamp
var defaultAngDamp


@export_range(1, 10, 0.5) var handling: float = 0.4
@export_range(1, 30, 0.5) var dampingControl: float = 15
@export_range(200, 2000, 0.5) var rotationSpeed: float = 1000
@export_range(0, 20, 1) var angularDampWhenGrabbed: float = 18
@export var respawnDistance: int = 1000  # the point on the y axis an object must reach before respawning

#region built-ins
func _ready():
	get_tree().root.size_changed.connect(_on_size_changed) # So we have a signal to know when the game window is resized.
	_on_size_changed() # This is called to set screenSpace to the initial value
	spawnPos = position
	defaultDamp = linear_damp
	defaultAngDamp = angular_damp

func _process(delta):

	if (check_if_grabbed()):
		move(delta)
	
	if (position.y > respawnDistance):
		respawn()

#endregion

#region custom

#This function turns the mouse coordinates to a 0-1 scale instead of the full resolution of the screen
func translate_position(originalPositionData: Vector2):
	var alteredPos = (originalPositionData / screenSpace)
	
	return alteredPos
	
func check_if_grabbed():
	
	if (Input.is_action_just_released("LeftMouse")):
		isGrabbed = false
		gravity_scale = 1
		angular_damp = defaultAngDamp
		linear_damp = defaultDamp
	elif (isGrabbed == true && Input.is_action_pressed("LeftMouse")):
		isGrabbed = true
		gravity_scale = 0
		linear_damp = dampingControl
	elif (Input.is_action_just_pressed("LeftMouse") && mouseOver):
		isGrabbed = true
		
	return isGrabbed

func move(delta):
	var t = delta * handling
	var translatedMousePos = translate_position(get_viewport().get_mouse_position()) / 2 
	var myTranslatedPos = translate_position(position)
	var forceVector
	
	myTranslatedPos = myTranslatedPos.lerp(translatedMousePos, t)
	
	forceVector = -((myTranslatedPos - translatedMousePos) * screenSpace * delta * (handling * 1000))
	apply_central_force(forceVector)
	
	if (Input.is_action_pressed("Q")):
		apply_torque(-rotationSpeed)
		angular_damp = angularDampWhenGrabbed
		
	if (Input.is_action_pressed("E")):
		apply_torque(rotationSpeed)
		angular_damp = angularDampWhenGrabbed
	
func respawn():
	position = spawnPos
	
#endregion

#region Signal Functions
func _on_mouse_hitbox_mouse_entered():
	mouseOver = true

func _on_mouse_hitbox_mouse_exited():
	mouseOver = false
	
func _on_size_changed():
	screenSpace = get_viewport().get_visible_rect().size
	
#endregion
