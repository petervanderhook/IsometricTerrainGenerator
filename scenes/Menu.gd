extends Control

onready var btn = $TextureButton
onready var menu = $ItemList

export(Array, String) var menu_items

func _ready():
	for item in menu_items:
		menu.add_item(item)

func _on_Button_pressed():
	menu.popup()
