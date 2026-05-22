extends Node2D

@export var mob_scene: PackedScene
@export var max_mobs: int = 10
@onready var spawn_timer: Timer = $SpawnTimer
func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_mobs_if_needed()

func _on_spawn_timer_timeout() -> void:
	spawn_mobs_if_needed()

func spawn_mobs_if_needed():
	var current_mobs = get_tree().get_nodes_in_group("mobs").size()
	while current_mobs < max_mobs:
		spawn_single_mob()
		current_mobs += 1

func spawn_single_mob():
	if not mob_scene: return
	var mob = mob_scene.instantiate()
	mob.add_to_group("mobs")
	mob.global_position = get_spawn_position()
	
	get_parent().call_deferred("add_child", mob)

func get_spawn_position() -> Vector2:
	var markers: Array = []
	
	var random_offset = Vector2(randf_range(-2700, 1500), randf_range(-500, 500))
	return global_position + random_offset
