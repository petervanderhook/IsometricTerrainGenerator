extends ItemList

var is_hovered = false

func _on_ItemList_mouse_entered():
	is_hovered = true


func _on_ItemList_mouse_exited():
	is_hovered = false
