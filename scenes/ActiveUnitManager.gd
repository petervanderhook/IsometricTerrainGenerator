extends YSort

func get_units_with_los():
	var visible_units = []
	for unit in get_children():
		if unit.owned_by_player:
			visible_units.append(unit)
	return visible_units
