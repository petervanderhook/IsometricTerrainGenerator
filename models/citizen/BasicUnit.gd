extends KinematicBody2D

# Constants
const IS_UNIT = true
const IS_BUILDING = false
const PASSABLE_TILES = [2, 3, 4, 5]

# ONready Vars
onready var navigator = find_parent("Root").find_node("Navigation2D")
onready var user_selected_light = $UserSelected
onready var speed = 45
onready var root = find_parent("Root")
onready var nav = root.find_node('ActiveGame')
onready var terrain_map = nav.find_node("TerrainMap")
onready var rays = $Rays
onready var ray_front = $Rays/Front
onready var fog_map = nav.find_node("FogMap")

enum States {IDLE, MOVING, ATTACKING, BUILDING}
var state = States.IDLE
var start_zoom = Vector2.ONE
var velocity = Vector2.ZERO
var target = Vector2.ZERO
var move_satisfaction_distance = 10
var last_assigned_pos
var owned_by_player = true
var line_of_sight = 256


#  New Movement Vars
var assigned_tile = []
var last_tile = []
var current_tile = []

var path := PoolVector2Array()
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	last_tile = terrain_map.world_to_map(global_position)
	assigned_tile = terrain_map.world_to_map(global_position)
	last_assigned_pos = terrain_map.world_to_map(global_position)
	current_tile = terrain_map.world_to_map(global_position)
	unselect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_speed()
	
	# Gets the current tile the unit is on
	current_tile = terrain_map.world_to_map(global_position)
	
	
	if (state == States.MOVING):
		set_collision_layer_bit(3, false)
		set_collision_layer_bit(2, true)
	elif state == States.IDLE:
		set_collision_layer_bit(3, true)
		set_collision_layer_bit(2, false)
	if selected:
		#print()
		#print("1: ", get_collision_layer_bit(1), " 2: ", get_collision_layer_bit(2))
		pass
	if Input.is_action_just_pressed("right_click"):
		if selected:
			# Old Movement
			assigned_tile = terrain_map.world_to_map(get_global_mouse_position())
			print("Moving from: ", terrain_map.world_to_map(global_position), " to : ", assigned_tile)
			#old_move()
		else:
			#print(terrain_map.world_to_map(get_global_mouse_position()))
			print(terrain_map.map_to_world(terrain_map.world_to_map(get_global_mouse_position())))
	#old_move_process()
	if current_tile != assigned_tile:
		state = States.MOVING
		new_move_process()
	else:
		state = States.IDLE
		velocity = Vector2.ZERO

func new_move_process():
	if start_zoom != nav.scale:
		start_zoom = nav.scale
	var possible_tiles = get_valid_tiles(current_tile)
	var lowest_value = 99999
	var chosen_tile = current_tile
	if current_tile == assigned_tile:
		return
	# GET chosen tile
	for tile in possible_tiles:
		var value = abs(get_manhattan_distance(tile, assigned_tile))
		if value < lowest_value:
			chosen_tile = tile
			lowest_value = value
		print(tile, " ", value)
	print("Current Tile: ", current_tile, " Assigned Tile: ", assigned_tile, " Chosen Tile: ", chosen_tile, " Value: ", lowest_value)
	var top_tile_pos = terrain_map.map_to_world(Vector2(chosen_tile[0], chosen_tile[1]))
	top_tile_pos = Vector2(top_tile_pos.x, top_tile_pos.y + 32)
	print("Moving to: ", top_tile_pos)
	move_to_position(terrain_map.map_to_world(Vector2(chosen_tile[0], chosen_tile[1])))
		#(global_position.distance_to(terrain_map.map_to_world(chosen_tile)) > (move_satisfaction_distance)):
		

func get_manhattan_distance(tile, target_tile):
	
	var target_tile_position = terrain_map.map_to_world(Vector2(target_tile[0], target_tile[1]))
	var start_tile_position = terrain_map.map_to_world(Vector2(tile[0], tile[1]))
	var return_val = (start_tile_position.x - target_tile_position.x) + (start_tile_position.y - target_tile_position.y)
	return return_val
	
func get_valid_tiles(tile):
	var x = tile[0]
	var y = tile[1]
	# Adjacent Tiles.
	var north = false
	var west = false
	var east = false
	var south = false
	var adj_tiles = [ [x, y-1], [x-1, y], [x+1, y], [x, y+1] ]
	var diag_tiles = [ [x-1, y-1], [x+1, y-1], [x-1, y+1], [x+1, y+1] ]
	var valid_tiles = []
	if terrain_map.get_cell(adj_tiles[0][0], adj_tiles[0][1]) in PASSABLE_TILES:
		north = true
		valid_tiles.append(adj_tiles[0])
	if terrain_map.get_cell(adj_tiles[1][0], adj_tiles[1][1]) in PASSABLE_TILES:
		west = true
		valid_tiles.append(adj_tiles[1])
	if terrain_map.get_cell(adj_tiles[2][0], adj_tiles[2][1]) in PASSABLE_TILES:
		east = true
		valid_tiles.append(adj_tiles[2])
	if terrain_map.get_cell(adj_tiles[3][0], adj_tiles[3][1]) in PASSABLE_TILES:
		south = true
		valid_tiles.append(adj_tiles[3])
	
	if north and west:
		valid_tiles.append(diag_tiles[0])
	if north and east:
		valid_tiles.append(diag_tiles[1])
	if south and west:
		valid_tiles.append(diag_tiles[2])
	if south and east:
		valid_tiles.append(diag_tiles[3])
			
	return valid_tiles

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
		var viable_ray = get_valid_ray()
		if viable_ray:
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


func get_viewed_tiles():
	# Returns tiles in range of the units line of sight
	var return_list = []
	var start_tile = fog_map.world_to_map(global_position)
	for x in range( -5, 5):
		for y in range(-5, 5):
			if global_position.distance_to(fog_map.map_to_world(Vector2(x, y))) < line_of_sight:
				return_list.append([x, y])
	
	#print("Returning: ", return_list)
	return return_list

func update_speed():
	speed = 45 * nav.scale

func old_move():
	#print("Clicked")
	var mouse_pos = get_global_mouse_position()
	var current_pos = global_position
	var new_path = nav.get_simple_path(current_pos, mouse_pos, true)
	target = mouse_pos
	start_zoom = nav.scale
	if len(new_path) > 0:
		set_path(new_path)
		last_assigned_pos = path[0]
	else:
		global_position += Vector2(0, 0.001)
		
		
func old_move_process():
	if len(path) > 0:
		if start_zoom != nav.scale:
			target = nav.scale * (target / start_zoom)
			path = nav.get_simple_path(global_position, target)
			start_zoom = nav.scale
			if len(path) == 0:
				path = []
				state = States.IDLE
				velocity = Vector2.ZERO
		if global_position.distance_to(path[0]) > (move_satisfaction_distance):
			move_to_position(last_assigned_pos / nav.scale)
			
		elif len(path) > 1:
			path.remove(0)
			last_assigned_pos = path[0]
			move_to_position(last_assigned_pos / nav.scale)
		else:
			path = []
			state = States.IDLE
			velocity = Vector2.ZERO
