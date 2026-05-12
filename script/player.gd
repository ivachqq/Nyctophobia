extends CharacterBody2D

enum { DOWN, UP, LEFT, RIGHT }
@onready var health_bar = $CanvasLayer/HealthBar
@onready var battery_bar = $CanvasLayer/BatteryBar   # <-- новая ссылка
@onready var anim = $AnimatedSprite2D
@onready var flashlight_pivot = $FlashLightPivot
@onready var flashlight_sprite = $FlashLightPivot/FlashLightSprite
var flashlight_on = false
var speed = 150
var idle_dir = DOWN
var max_health = 3
var current_health = 3
var armor = 0

# Батарея фонарика
var battery_max: float = 100.0
var battery: float = battery_max
var battery_drain_rate: float = 15.0   # единиц в секунду (можно настроить)

func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	battery_bar.max_value = battery_max   # <-- максимум шкалы
	battery_bar.value = battery           # текущий заряд
	
	flashlight_sprite.scale = Vector2(0.08, 0.08)
	flashlight_sprite.modulate = Color(1, 1, 1, 0.5)

func take_damage(amount: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	var final_damage = amount - armor
	if final_damage < 0: final_damage = 0
	current_health -= final_damage
	health_bar.value = current_health
	if current_health <= 0:
		die()

func die():
	get_tree().change_scene_to_file("res://scene/world.tscn")

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO 

	if Input.is_action_pressed("up"):
		up_move()
	elif Input.is_action_pressed("down"):
		down_move()
	elif Input.is_action_pressed("left"):
		left_move()
	elif Input.is_action_pressed("right"):
		right_move()
	else: 
		idle()

	move_and_slide()

	# Расход батареи, если фонарик включен
	if flashlight_on:
		if battery > 0:
			battery -= battery_drain_rate * delta
			battery_bar.value = battery   # <-- обновляем шкалу
			if battery <= 0:
				battery = 0
				battery_bar.value = 0
				battery_empty()
		else:
			battery_empty()

func up_move():
	anim.play("Up")
	velocity.y = -speed
	idle_dir = UP

func down_move():
	anim.play("down")
	velocity.y = speed
	idle_dir = DOWN

func left_move():
	anim.flip_h = true
	anim.play("Front")
	velocity.x = -speed
	idle_dir = LEFT

func right_move():
	anim.flip_h = false
	anim.play("Front")
	velocity.x = speed
	idle_dir = RIGHT

func _input(event):
	if event.is_action_pressed("toggle_flashlight"):
		if battery <= 0:
			battery_empty()
			return
		flashlight_on = not flashlight_on
		flashlight_sprite.visible = flashlight_on
		if flashlight_on:
			update_flashlight_angle()

	if event is InputEventMouseMotion and flashlight_on:
		update_flashlight_angle()

func update_flashlight_angle():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	flashlight_pivot.rotation = dir.angle() - PI/2

func battery_empty():
	flashlight_on = false
	flashlight_sprite.visible = false
	get_tree().change_scene_to_file("res://scene/world.tscn")

func idle():
	match idle_dir:
		DOWN: anim.play("Idle_down")
		UP: anim.play("Idle_up")
		LEFT: 
			anim.flip_h = true
			anim.play("Idle_front")
		RIGHT: 
			anim.flip_h = false
			anim.play("Idle_front")
