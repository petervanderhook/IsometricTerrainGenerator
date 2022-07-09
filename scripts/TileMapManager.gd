extends TileMap
#### Chunks ####
# size = 32x32
# Load off perlin noise
# Export to array for server
# Find way to change seed
# Define some presets

#### Algorithm Notes ####
# Order:
# Generate Land, Water, Mountains off perlin noise
# No need to iterate as the noise is already made.
# Generate beaches and coastal water
# Generate Plains and Forests
# Generate other objects
# Generate Rivers last

#### Algorithm for rivers ####
# Options:
# How common, How long, Larger or smaller rivers
# 
# Generate start point
# Generate follow point in direction of the nigga with some calculations to add variance
# Re-iterate previous line until at acceptable distance for the river, maybe predefine these at the start. 
# This should be done after the map is generated

#### Algorithms for beaches ####
# Options:
# Big or small beaches
# 
# Only should run for large bodies of water
# Convert land tiles adjacent to large bodies of water beaches
# Maybe add a second iteration to make beaches a bit larger 
# eg. If adj tiles count > 3 for sand then they should be set.

#### Algorithms for deep ocean ####
# Options:
# How much ocean do you want
# 
# Only should run for large bodies of water
# default ocean and calc coast (i think)
# 

#### Algorithm for plains ####
# Options:
# How common (should this counter forests?), size
# 
# Generate in large fields of grass n shit iguess, figure it out later

#### Algorithm for forests ####
# Options: 
# Size, How common
# 
# Also should generate on plains
# Probably happens after the initial world is generated
# Should cluster

#### Algorithm for mountains ####
# Options:
# Enable or disable, size of ranges
# 
# Should have a tilemap for a mountain range or something like that
# Should be generated with the initial land gen.
# Impassable and op


### Notes ###
# What if I generate the map first
# without changing the tiles instead of iterating and taking into account new tiles
# try later i guess

var count = 0
var time = 0
var time_to_wait = 0.0
var time_to_iterate = 0.0
var rng = RandomNumberGenerator.new()
var tile_array = []
var init_coords = []
var rendered_chunks = []
var iterated_cells = []
var generated = false
var iterating = false
var tree_biome_tiles = []
var river_biome_tiles = []
var rock_biome_tiles = []
var field_biome_tiles = []
var global_seed = 1470
var seed_input

onready var perlin_terrain = get_parent().find_node("PerlinTerrain")
onready var perlin_trees = get_parent().find_node("PerlinTrees")
onready var perlin_fields = get_parent().find_node("PerlinFields")
onready var perlin_rivers = get_parent().find_node("PerlinRivers")
onready var perlin_rocks = get_parent().find_node("PerlinRocks")
onready var fog_map = get_parent().find_node("FogMap")

# Export Vars for map generation
export var min_distance_per_river = 30
export var min_distance_per_rock = 12
export var x_bounds = [0, 32]
export var y_bounds = [0, 32]
export var world_size = 8
export var iteration_count =3 

func _ready():
	count = 0
	time = 0
	time_to_wait = 0.0
	rng.randomize()
	seed_input = find_parent("Root").find_node("textinput")
	seed_input.text = str(global_seed)
	init_world()

func _process(delta):
	if Input.is_action_just_pressed("space"):
		count = 0
		time = 0
		time_to_wait = 0.0
		perlin_terrain.texture.noise.seed = int(seed_input.text)
		init_world()

# X: Range is 4096 (-2048, 2048)
# Y: Range is 2048 (0, 2048)
func generate_chunk(dimensions):
	if str(dimensions[0]).substr(0, 1) == "-":
		return
	if str(dimensions[1]).substr(0, 1) == "-":
		return
	if dimensions in rendered_chunks:
		return
	if dimensions[0] > (world_size -1):
		return
	if dimensions[1] > (world_size -1):
		return
	
	var x_multiplier = dimensions[0]
	var y_multiplier = dimensions[1]
	var x_start = 0 + (32 * x_multiplier)
	var y_start = 0 + (32 * y_multiplier)
	
	tile_array = []
	for i in range(x_start, x_start + 32):
		for j in range(y_start, y_start + 32):
			tile_array.append([i, j])
	
	init_coords = [] + tile_array
	while (len(init_coords) > 0):
		var chosen_tile = init_coords.pop_at(floor(rng.randf_range(0, len(init_coords))))
		var chosen_value = perlin_terrain.texture.noise.get_noise_2d(chosen_tile[0], chosen_tile[1])
		generate_tile(chosen_tile, chosen_value)
	generated = true
	time_to_iterate = time + 1
	rendered_chunks.append(dimensions)

func generate_tile(coord_array, value):
	var tile_num
	var valid_tree_tile
	var valid_mountain_tile
	var valid_river_tile
	var valid_rock_tile
	var valid_fish_tile
	var valid_field_tile
	if value < -0.15:
		tile_num = 1
		if value < -0.3:
			tile_num = 0
	else:
		tile_num = 2
		if value > -0.05:
			valid_rock_tile = true
			valid_field_tile = true
			valid_tree_tile = true
			tile_num = 3
			if value > 0.1:
				if value > .6:
					valid_rock_tile = false
					valid_field_tile = false
					valid_tree_tile = false
					valid_river_tile = true
					tile_num = 7
				elif value > .35:
					valid_river_tile = true
	
	if valid_tree_tile:
		tree_biome_tiles.append(coord_array)
	if valid_river_tile:
		river_biome_tiles.append(coord_array)
	if valid_rock_tile:
		rock_biome_tiles.append(coord_array)
	if valid_field_tile:
		field_biome_tiles.append(coord_array)
	set_cell(coord_array[0], coord_array[1], tile_num)

func get_global_seed():
	print("Seed obtained: ", seed_input.text)
	return int(seed_input.text)

func set_texture_seed(seed_fetched):
	perlin_rivers.texture.noise.set_seed(seed_fetched)
	perlin_terrain.texture.noise.set_seed(seed_fetched)
	perlin_trees.texture.noise.set_seed(seed_fetched)
	perlin_fields.texture.noise.set_seed(seed_fetched - 1000)
	print("River seed: ", perlin_rivers.texture.noise.seed, "\nTerrain Seed: ", perlin_terrain.texture.noise.seed, "\nTrees Seed: ", perlin_trees.texture.noise.seed, "\nFields Seed: ", perlin_fields.texture.noise.seed)

func get_tile_types(tile_list):
	var type_list = []
	for tile in tile_list:
		type_list.append(get_cell(tile[0], tile[1]))
	return type_list
	
func get_adjacent_tiles_four(tile_coord):
	# Coords
	var x = tile_coord[0]
	var y = tile_coord[1]
	# Adjacent Tiles.
	var nw_tile = [x-1, y-1]
	var n_tile = [x, y-1]
	var ne_tile = [x+1, y-1]
	var w_tile = [x-1, y]
	var e_tile = [x+1, y]
	var sw_tile = [x-1, y+1]
	var s_tile = [x, y+1]
	var se_tile = [x+1, y+1]
	var adj_tiles = [n_tile, w_tile, e_tile, s_tile]
	return adj_tiles
		

func delete_world():
	for cell in get_used_cells():
		set_cell(cell[0], cell[1], -1)

func init_world():
	global_seed = get_global_seed()
	set_texture_seed(global_seed)
	#Set Bounds for Fog of War
	fog_map.x_bounds = x_bounds
	fog_map.y_bounds = y_bounds
	
	# Reset biome arrays
	tree_biome_tiles = []
	river_biome_tiles = []
	rock_biome_tiles = []
	field_biome_tiles = []
	# Unrender all tiles on the world
	delete_world()
	
	# Reset generation vars
	iterated_cells = []
	rendered_chunks = []
	
	# Set bools for _process
	iterating = false
	generated = false
	
	var gen_list = []
	for b in range(0, world_size):
		for c in range(0, world_size):
			gen_list.append([b, c])
	for genchunk in gen_list:
		generate_chunk(genchunk)
		initialize_fog(genchunk)
	
	print("Generating Trees")
	iterate_trees()
	print("Generating Fields")
	iterate_fields()
	print("Generating Rocks")
	iterate_rocks()
	print("Generating Rivers")
	iterate_rivers()
	#print("Finished")
	

func initialize_fog(chunk):
	fog_map.init_fog(chunk)
	
	
func iterate_trees():
	for tile in tree_biome_tiles:
		if perlin_trees.texture.noise.get_noise_2d(tile[0], tile[1]) > 0.25:
			set_cell(tile[0], tile[1], 6)

func iterate_fields():
	for tile in field_biome_tiles:
		if perlin_fields.texture.noise.get_noise_2d(tile[0], tile[1]) < -0.45:
			set_cell(tile[0], tile[1], 4)

func iterate_rivers():
	var created_river_tiles = []
	for tile in river_biome_tiles:
		var noise_value = perlin_rivers.texture.noise.get_noise_2d(tile[0], tile[1])
		if  (noise_value > 0.4):# and (noise_value < 0.405):
			created_river_tiles.append(tile)
			
	var invalid_rivers = []
	var valid_rivers = []
	
	for tile in created_river_tiles:
		if tile in invalid_rivers:
			continue
		valid_rivers.append(tile)
		for other_tile in created_river_tiles:
			if (other_tile[0] < (tile[0] + min_distance_per_river)) and (other_tile[0] > (tile[0] - min_distance_per_river)):
				if (other_tile[1] < (tile[1] + min_distance_per_river)) and (other_tile[1] > (tile[1] - min_distance_per_river)):
					invalid_rivers.append(other_tile)
	
	for river in valid_rivers:
		set_cell(river[0], river[1], 0)
		perlin_worm_river(river)

func iterate_rocks():
	var created_rock_tiles = []
	for tile in rock_biome_tiles:
		var noise_value = perlin_rocks.texture.noise.get_noise_2d(tile[0], tile[1])
		if noise_value > 0.4:
			created_rock_tiles.append(tile)
			
	var invalid_rocks = []
	var valid_rocks = []
	
	print("Checking for invalids")
	for tile in created_rock_tiles:
		if tile in invalid_rocks:
			continue
		valid_rocks.append(tile)
		for other_tile in created_rock_tiles:
			if (other_tile[0] < (tile[0] + min_distance_per_rock)) and (other_tile[0] > (tile[0] - min_distance_per_rock)):
				if (other_tile[1] < (tile[1] + min_distance_per_rock)) and (other_tile[1] > (tile[1] - min_distance_per_rock)):
					invalid_rocks.append(other_tile)
	print("Setting Rocks")
	for rock_tile in valid_rocks:
		set_cell(rock_tile[0], rock_tile[1], 5)

func perlin_worm_river(start_coords):
	var current_position = [] + start_coords
	var flowing = true
	var previous_tile = [] + current_position
	var past_tiles = [current_position]
	while flowing:
		var count = 0
		var highest_value_index = 0
		var adj_tiles = get_adjacent_tiles_four(current_position)
		var previous_highest_value = 1
		for tile in adj_tiles:
			var noise_value = perlin_terrain.texture.noise.get_noise_2d(tile[0], tile[1])
			if noise_value <= -0.17:
				return
			elif get_cell(tile[0], tile[1]) == -1:
				return
			if noise_value < previous_highest_value:
				if (previous_tile != adj_tiles[count]) and not adj_tiles[count] in past_tiles :
					previous_highest_value = noise_value
					highest_value_index = count
			count += 1
		
		previous_tile = current_position
		current_position = adj_tiles[highest_value_index]
		
		# Find out if went on x axis or y axis and adjust width appropriately
		set_cell(current_position[0], current_position[1], 0)
		past_tiles.append(current_position)
		
func calculate_bounds():
	var used_cells = get_used_cells()
	var result = {
		"x": 0,
		"y": 0,
		"w": 0,
		"h": 0
	}
	
	for pos in used_cells:
		pos *= 32
		if pos.x < result["x"]:
			result["x"] = int(pos.x)
		elif pos.x > result["w"]:
			result["w"] = int(pos.x)
		if pos.y < result["y"]:
			result["y"] = int(pos.y)
		elif pos.y > result["h"]:
			result["h"] = int(pos.y)
	
	return result
