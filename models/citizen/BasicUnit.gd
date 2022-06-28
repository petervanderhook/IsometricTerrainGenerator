extends KinematicBody2D

# Constants
const IS_UNIT = true
const IS_BUILDING = false

# ONready Vars
onready var navigator = get_parent().get_parent()
onready var user_selected_light = $UserSelected




var path := PoolVector2Array()
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	unselect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("right_click") and selected:
		print("Clicked")
		var mouse_pos = get_global_mouse_position()
		var current_pos = global_position
		print(current_pos, mouse_pos)


func select():
	selected = true
	user_selected_light.visible = true

func unselect():
	selected = false
	user_selected_light.visible = false


