extends Node2D

func _ready() -> void:
	if Global.has_sword:
		var sword = get_parent().find_child("SwordItem", true, false)
		if sword:
			sword.queue_free()
		queue_free()
		return

	var markers: Array = []
	for child in get_children():
		if child is Marker2D:
			markers.append(child)

	if markers.size() > 0:
		var sword = get_parent().find_child("SwordItem", true, false)
		if sword:
			var random_marker = markers[randi() % markers.size()]
			sword.global_position = random_marker.global_position
