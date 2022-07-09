extends Control

onready var btn = $TextureButton
onready var menu = $ItemList

export(Array, String) var menu_items

func _ready():
	for item in menu_items:
		menu.add_item(item)

func _process(_delta):
	if menu.visible and !menu.is_hovered and !btn.is_hovered and Input.is_action_just_pressed("left_click"):
		menu.visible = false

func _on_Button_pressed():
	menu.visible = !menu.visible
