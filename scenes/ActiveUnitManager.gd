extends YSort


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_units_with_los():
	var visible_units = []
	for unit in get_children():
		if unit.owned_by_player:
			visible_units.append(unit)
	return visible_units
