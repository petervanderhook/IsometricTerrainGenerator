extends TextureButton

var is_hovered = false

func _on_TextureButton_mouse_entered():
	is_hovered = true


func _on_TextureButton_mouse_exited():
	is_hovered = false
