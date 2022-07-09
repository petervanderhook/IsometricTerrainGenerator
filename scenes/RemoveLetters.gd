extends TextEdit

var time = 0.0

func _ready():
	text = str(get_parent().get_parent().get_parent().find_node("PerlinTerrain").texture.noise.seed)

func _process(delta):
	time += delta
	if time > 3.0:
		text = str(floor(rand_range(0, 5000)))
		time = 0
