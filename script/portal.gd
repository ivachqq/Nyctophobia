extends Area2D

@export_file("*.tscn") var target_level_path: String

func _on_body_entered(body: Node2D) -> void:
	print("да")
	if body.name == "player" or body is CharacterBody2D:
		if target_level_path != "":
			get_tree().change_scene_to_file(target_level_path)
		else:
			print("Ошибка: путь к уровню не задан!")
