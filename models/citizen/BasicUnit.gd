extends KinematicBody2D

# Constants
const IS_UNIT = true
const IS_BUILDING = false

# ONready Vars
onready var navigator = get_parent().get_parent().find_node("Navigation2D")
onready var user_selected_light = $UserSelected
onready var speed = 2


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
		last_assigned_pos = mouse_pos
	
	if global_position.distance_to(last_assigned_pos) > move_satisfaction_distance:
		move_to_position(last_assigned_pos)
	else:
		velocity = Vector2.ZERO


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


