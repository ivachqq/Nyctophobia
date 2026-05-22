extends Area2D

@export var health_bonus: int = 1
@export var flashlight_charge: float = 30.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.has_method("add_health"):
			body.add_health(health_bonus)
		
		if body.has_method("add_flashlight"):
			body.add_flashlight(flashlight_charge)
		
		queue_free()
