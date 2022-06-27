extends KinematicBody2D
var selected = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	selected = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		print(position)
		var mouse_pos = get_global_mouse_position()
		print(mouse_pos)
