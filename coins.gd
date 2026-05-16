extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.coins += 1
		body.update_ui()
		call_deferred("queue_free")
