extends Camera2D
onready var follow_point = get_parent().find_node("Camera Follow")
onready var tile_map = get_parent().find_node("TileMap")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED_HIGH = 30
const SPEED_MEDIUM = 20
const SPEED_LOW = 10

var speed_modifier = 1
var speed = SPEED_LOW
var zoom_amount = 0.25
var lerp_speed = 3.9
var wait_on_generate = 0.0
var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	var current_tile_on_focus = tile_map.world_to_map(transform.origin)
	var current_chunk = get_current_chunk(current_tile_on_focus)
	
	if tile_map.generated:
		#print("Chunk: ", current_chunk, "    Tile: ", current_tile_on_focus)
		if (tile_map.get_cell(current_tile_on_focus[0], current_tile_on_focus[1]) == -1) and (wait_on_generate < (time + 2)):
			wait_on_generate = time
			#print("Running: ", current_chunk)
			tile_map.generate_chunk([current_chunk[0], current_chunk[1]])
		
		pass
	#print(Vector2((follow_point.transform.origin.x / 128), (follow_point.transform.origin.y / 128)))
	transform.origin.x = lerp(transform.origin.x, follow_point.transform.origin.x, delta * lerp_speed)
	#print("Zoom X: ", zoom.x, "    Zoom Y: ", zoom.y)
	transform.origin.y = lerp(transform.origin.y, follow_point.transform.origin.y, delta * lerp_speed)
	#set_lin_velocity_on_just_press()
	if Input.is_action_just_pressed("shift"):
		speed *= 10
	elif Input.is_action_just_released("shift"):
		speed /= 10
	
	if Input.is_action_pressed('left'):
		follow_point.transform.origin.x -= speed
		transform.origin.x = lerp(transform.origin.x, follow_point.transform.origin.x, delta * lerp_speed)
	if Input.is_action_pressed('right'):
		follow_point.transform.origin.x += speed
		transform.origin.x = lerp(transform.origin.x, follow_point.transform.origin.x, delta * lerp_speed)
	if Input.is_action_pressed('up'):
		follow_point.transform.origin.y -= speed
		transform.origin.y = lerp(transform.origin.y, follow_point.transform.origin.y, delta * lerp_speed)
	if Input.is_action_pressed('down'):
		follow_point.transform.origin.y += speed
		transform.origin.y = lerp(transform.origin.y, follow_point.transform.origin.y, delta * lerp_speed)
	if Input.is_action_just_released('wheel_down'):
		if zoom.x < 10:
			zoom.x += zoom_amount
			zoom.y += zoom_amount
	if Input.is_action_just_released('wheel_up'):
		if zoom.y > 1:
			zoom.x -= zoom_amount
			zoom.y -= zoom_amount
	
	if zoom.x > 10:
		speed = 20
		zoom_amount = 1
	elif zoom.x > 5:
		speed = 12
		zoom_amount = 0.5
	else:
		speed = 6
		zoom_amount = 0.25
func set_lin_velocity_on_just_press():
	if Input.is_action_just_pressed("down"):
		follow_point.transform.origin = transform.origin
	if Input.is_action_just_pressed("up"):
		follow_point.transform.origin = transform.origin
	if Input.is_action_just_pressed("left"):
		follow_point.transform.origin = transform.origin
	if Input.is_action_just_pressed("right"):
		follow_point.transform.origin = transform.origin
		
		
		
		
func get_current_chunk(focused_tile):
	var y_positive = true
	var x_positive = true
	var focused_chunk = [0, 0]
	var x = focused_tile[0]
	var y = focused_tile[1]
	if x < 0:
		x_positive = false
		x *= -1
	if y < 0:
		y_positive = false
		y *= -1
	while x > 32:
		focused_chunk[0] += 1
		x -= 32
	while y > 32:
		focused_chunk[1] += 1
		y -= 32
	var return_chunk = []
	if x_positive:
		return_chunk.append(focused_chunk[0])
	else:
		return_chunk.append(focused_chunk[0] * -1)
	if y_positive:
		return_chunk.append(focused_chunk[1])
	else:
		return_chunk.append(focused_chunk[1] * -1)
	
	if !x_positive:
		if return_chunk[0] == 0:
			return_chunk[0] = "-0"
	if !y_positive:
		if return_chunk[1] == 0:
			return_chunk[1] = "-0"
	return return_chunk
