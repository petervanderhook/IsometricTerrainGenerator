extends Node2D

# Constants
const IS_UNIT = true
const IS_BUILDING = false

# ONready Vars
onready var navigator = get_parent().get_parent().find_node("Navigation2D")
onready var user_selected_light = $UserSelected
onready var speed = 2
onready var root = get_parent().get_parent()
onready var nav = root.find_node('ActiveGame')



var velocity = Vector2.ZERO
var target = Vector2.ZERO
var move_satisfaction_distance = 7
var last_assigned_pos

var path := PoolVector2Array()
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	last_assigned_pos = global_position
	unselect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left_click") and selected:
		#print("Clicked")
		var mouse_pos = get_global_mouse_position()
		var current_pos = global_position
		print(current_pos, mouse_pos)
		var new_path = nav.get_simple_path(current_pos, mouse_pos, true)
		if len(new_path) > 0:
			set_path(new_path)
			print(path)
			last_assigned_pos = path[0]
	if len(path) > 0:	
		if global_position.distance_to(path[0]) > move_satisfaction_distance:
			move_to_position(last_assigned_pos)
		elif len(path) > 1:
			path.remove(0)
			last_assigned_pos = path[0]
		else:
			velocity = Vector2.ZERO

func set_path(new_path):
	path = new_path

func select():
	selected = true
	user_selected_light.visible = true

func unselect():
	selected = false
	user_selected_light.visible = false
	
	
func move_to_position(pos):
	#print(velocity)
	velocity = position.direction_to(pos) * speed
	#if position.distance_to(pos) < move_satisfaction_distance:
	#print("Direction to: ", global_position.direction_to(pos))
	#print("Moving to ", pos, " at velocity: ", velocity)
	velocity = move_and_collide(velocity)


