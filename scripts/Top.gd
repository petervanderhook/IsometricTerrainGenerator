extends PanelContainer

onready var camera = find_parent("Camera2D")

onready var margins = {
	"top": margin_top,
	"left": margin_left,
	"right": margin_right,
	"bottom": margin_bottom
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	margin_top = margins["top"] * camera.zoom.y
	margin_bottom = margins["bottom"] * camera.zoom.y
	margin_left = margins["left"] * camera.zoom.x
	margin_right = margins["right"] * camera.zoom.x
