extends Area2D

@onready var coinSound = $coinGetSound

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		set_deferred("monitoring", false)
		hide()
		body.coins += 1
		body.update_ui()
		coinSound.play()
		await coinSound.finished
		queue_free()
