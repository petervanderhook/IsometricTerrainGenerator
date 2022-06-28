extends Node2D

var dragging = false
var selected = []
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
const terrain_ids = [1358, 1374]

onready var select_draw = find_node("SelectNode")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		# Just clicked the button, potentially start dragging.
		if event.pressed:
			for unit in selected:
				if not unit.collider in $Units.get_children():
					continue
				unit.collider.unselect()
			selected = []
			drag_start = get_global_mouse_position()
			dragging = true
		elif dragging:
			dragging = false
			var drag_end = get_global_mouse_position()
			select_draw.update_status(drag_start, drag_end, dragging)
			select_rect.extents = (drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var space_query = Physics2DShapeQueryParameters.new()
			space_query.set_shape(select_rect)
			space_query.transform = Transform2D(0, (drag_end + drag_start)/2)
			print("S: ", drag_start, " E:", drag_end)
			print((select_rect.get_extents()[0]*2), " ", (select_rect.get_extents()[1]*2))
			selected = space.intersect_shape(space_query)
			var updated_selected = []
			print ($Units.get_children())
			for unit in selected:
				if not unit.collider in $Units.get_children():
					continue
				print(unit.collider_id, unit)
				if unit.collider.IS_UNIT:
					unit.collider.select()
				updated_selected.append(unit)
			selected = updated_selected
		
	if dragging:
		#print("Dragging")
		if event is InputEventMouseMotion:
			#print("Moving")
			select_draw.update_status(drag_start, get_global_mouse_position(), dragging)

