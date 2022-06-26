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
	var new_text = ""
	for character in text:
		if character.is_valid_integer():
			new_text += character
		if len(new_text) >= 20:
			break
	text = new_text
		
