extends Area2D
@export var item_id: String = "book" 

var is_player_near: bool = false

func _ready() -> void:
	if item_id == "book" and Global.has_book:
		queue_free()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	input_event.connect(_on_input_event)
	

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		is_player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player"):
		is_player_near = false

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_player_near and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pick_up_item()

func pick_up_item():
	
	if item_id == "book":
		Global.has_book = true
	var player = get_tree().current_scene.find_child("player", true, false)
	if player and player.has_method("update_ui"):
		player.update_ui()

	queue_free()
