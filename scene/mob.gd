extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
var speed = 100
var player = null

func _physics_process(delta: float) -> void:
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist > 1:
			var dir = (player.global_position - global_position).normalized()
			velocity = dir * speed
			anim.play("walk")
			anim.flip_h = dir.x < 0
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			anim.play("Idle")
	else:
		velocity = Vector2.ZERO
		anim.play("Idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player = body
		print("Враг тебя заметил!")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player = null
		print("Враг потерял тебя из виду")
