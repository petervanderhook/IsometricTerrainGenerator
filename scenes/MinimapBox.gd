extends ViewportContainer
onready var viewport = $Viewport
var time = 0.0

func _process(delta):
	time += delta
	if time > 1:
		time = 0
		if viewport.render_target_update_mode != Viewport.UPDATE_ONCE:
			viewport.render_target_update_mode = Viewport.UPDATE_ONCE
