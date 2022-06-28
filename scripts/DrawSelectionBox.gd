extends Node2D

var drag_start = Vector2.ZERO
var drag_end = Vector2.ZERO
var dragging = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	if dragging:
		#print("Drawing from: ", drag_start, " to: ", drag_end - drag_start)
		draw_rect(Rect2(drag_start, drag_end - drag_start), Color(1, 1, 1, .5), true)
		
		
func update_status(start, end, drag):
	drag_start = start
	drag_end = end
	dragging = drag
	update()
