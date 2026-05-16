extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.has_sword = true
		body.update_ui()
		queue_free()
