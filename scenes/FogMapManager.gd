extends TileMap
var x_bounds = [0, 0]
var y_bounds = [0, 0]
var viewed_tiles = []
var time = 0.0

onready var active_units = get_parent().find_node("ActiveUnits")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 0.5:
		time = 0
		update_viewed_tiles()

func update_viewed_tiles():
	var new_viewed_tiles = []
	for unit in active_units.get_units_with_los():
		for tile in unit.get_viewed_tiles():
			if not tile in new_viewed_tiles:
				new_viewed_tiles.append(tile)
		
	print(len(new_viewed_tiles))
	for tile in viewed_tiles:
		if not tile in new_viewed_tiles:
			set_cell(tile[0], tile[1], 1)
	for tile in new_viewed_tiles:
		set_cell(tile[0], tile[1], -1)
	viewed_tiles = new_viewed_tiles


func init_fog(chunk_bounds):
	var x_start = 0 + (32 * chunk_bounds[0])
	var y_start = 0 + (32 * chunk_bounds[1])
	print(x_bounds, y_bounds)
	for x_index in range(x_start-1, x_start+34):
		for y_index in range(y_start-1, y_start+34):
			#print("Setting cell ", x_index, ", ", y_index)
			set_cell(x_index, y_index, 0)
