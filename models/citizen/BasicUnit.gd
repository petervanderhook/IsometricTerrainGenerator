extends KinematicBody2D

# Constants
const IS_UNIT = true
const IS_BUILDING = false

# ONready Vars
onready var navigator = find_parent("Root").find_node("Navigation2D")
onready var user_selected_light = $UserSelected
onready var speed = 85
onready var root = find_parent("Root")
onready var nav = root.find_node('ActiveGame')
onready var rays = $Rays
onready var ray_front = $Rays/Front

enum States {IDLE, MOVING, ATTACKING, BUILDING}
var state = States.IDLE
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
	if (state == States.MOVING):
		set_collision_layer_bit(3, false)
		set_collision_layer_bit(2, true)
	elif state == States.IDLE:
		set_collision_layer_bit(3, true)
		set_collision_layer_bit(2, false)
	if selected:	
		print("1: ", get_collision_layer_bit(1), " 2: ", get_collision_layer_bit(2))
	if Input.is_action_just_pressed("right_click") and selected:
		#print("Clicked")
		var mouse_pos = get_global_mouse_position()
		var current_pos = global_position
		print(current_pos, mouse_pos)
		var new_path = nav.get_simple_path(current_pos, mouse_pos, true)
		if len(new_path) > 0:
			set_path(new_path)
			print(path)
			last_assigned_pos = path[0]
		else:
			global_position += Vector2(0, 0.001)
	if len(path) > 0:
		state = States.MOVING
		if global_position.distance_to(path[0]) > move_satisfaction_distance:
			move_to_position(last_assigned_pos)
		elif len(path) > 1:
			path.remove(0)
			last_assigned_pos = path[0]
			move_to_position(last_assigned_pos)
		else:
			path = []
			state = States.IDLE
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
	velocity = position.direction_to(pos) * speed
	move_with_avoid()

func move_with_avoid():
	rays.rotation = velocity.angle()
	if obstacle_ahead():
		print("OBSTACLE")
		var viable_ray = get_valid_ray()
		if viable_ray:
			#var temp_point = viable_ray.get_child(0).global_position
			#path.insert(0, temp_point)
			#last_assigned_pos = temp_point
			velocity = Vector2.RIGHT.rotated(rays.rotation + viable_ray.rotation) * speed
	move_and_slide(velocity)
	move_and_slide(velocity)
	move_and_slide(velocity)

func obstacle_ahead():
	return ray_front.is_colliding()
	
func get_valid_ray():
	for ray in rays.get_children():
		if !ray.is_colliding():
			return ray
	return null
