extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(get_parent().get_parent().get_parent().find_node("PerlinTerrain").texture.noise.seed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(floor(rand_range(0, 5000)))
		
