extends Area2D

@export_file("*.tscn") var target_level_path: String

@export var target_door_name: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if target_level_path != "":
			Global.coins = body.coins
			Global.has_sword = body.has_sword
			Global.current_health = body.current_health
			
			Global.target_door_name = target_door_name
			
			get_tree().call_deferred("change_scene_to_file", target_level_path)
