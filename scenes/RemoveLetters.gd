extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(get_parent().get_parent().get_parent().find_node("PerlinTerrain").texture.noise.seed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 3.0:
		text = str(floor(rand_range(0, 5000)))
		time = 0
		
