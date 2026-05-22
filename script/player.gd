extends CharacterBody2D

@onready var book_icon = $CanvasLayer/BookIcon
@onready var banka_icon = $CanvasLayer/BankaIcon
@onready var zvetok_icon = $CanvasLayer/zvetokIcon

enum { DOWN, UP, LEFT, RIGHT }
@onready var health_bar = $CanvasLayer/HealthBar
@onready var battery_bar = $CanvasLayer/BatteryBar
@onready var anim = $AnimatedSprite2D
@onready var flashlight_pivot = $FlashLightPivot
@onready var flashlight_sprite = $FlashLightPivot/FlashLightSprite
@onready var flashlight_sound = $lanternSound
@onready var sword_sound = $swordSound

var flashlight_on = false
var speed = 150
var idle_dir = DOWN
var max_health = 3
var current_health = 3
var armor = 0

# Батарея фонарика
var battery_max: float = 100.0
var battery: float = battery_max
var battery_drain_rate: float = 1.0

# Атака и предметы
var is_attacking = false
var has_sword = false
var coins = 0

@onready var sword_icon = $CanvasLayer/SwordIcon
@onready var coin_label = $CanvasLayer/CoinLabel
@onready var flashlight_ray = $FlashLightPivot/FlashlightRay

# Диалог
var dialogue_lines: Array = []
var current_line_index: int = 0
@onready var dialogue_box = $CanvasLayer/DialogueBox
@onready var dialogue_text = $CanvasLayer/DialogueBox/DialogueText

func _ready():
	# Загружаем глобальные данные
	coins = Global.coins
	has_sword = Global.has_sword
	current_health = Global.current_health

	health_bar.max_value = max_health
	health_bar.value = current_health

	battery_bar.max_value = battery_max
	battery_bar.value = battery

	flashlight_sprite.scale = Vector2(0.08, 0.08)
	flashlight_sprite.modulate = Color(1, 1, 1, 0.5)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	update_ui()
	if Global.has_book:
		book_icon.modulate.a = 1.0
	if Global.has_banka:
		banka_icon.modulate.a = 1.0
	if Global.has_zvetok:
		zvetok_icon.modulate.a = 1.0

	# Если нужно телепортироваться к определённой двери
	if Global.target_door_name != "":
		var spawn_point = get_tree().current_scene.find_child(Global.target_door_name, true, false)
		if spawn_point:
			global_position = spawn_point.global_position

func _input(event: InputEvent) -> void:
	# Сначала диалог (если активно)
	if dialogue_box.visible:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			current_line_index += 1
			show_current_line()
			get_viewport().set_input_as_handled()
			return

	# Атака
	if event.is_action_pressed("attack") and has_sword:
		attack()

	# Фонарик
	if event.is_action_pressed("toggle_flashlight"):
		if battery <= 0:
			battery_empty()
			return
		flashlight_on = not flashlight_on
		flashlight_sprite.visible = flashlight_on
		flashlight_sound.play()
		if flashlight_on:
			update_flashlight_angle()

	# Поворот фонарика при движении мыши
	if event is InputEventMouseMotion and flashlight_on:
		update_flashlight_angle()

func attack():
	if has_sword and not is_attacking:
		is_attacking = true
		sword_sound.play()
		anim.play("attack")
		$AttackZone.monitoring = true

		await get_tree().create_timer(0.1).timeout
		var bodies = $AttackZone.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage") and body != self:
				body.take_damage(1)

		await get_tree().create_timer(0.3).timeout
		is_attacking = false
		$AttackZone.monitoring = false

func _physics_process(delta: float) -> void:
	if not is_attacking:
		# Строим вектор направления по всем нажатым клавишам
		var input_dir = Vector2.ZERO
		if Input.is_action_pressed("right"):
			input_dir.x += 1
		if Input.is_action_pressed("left"):
			input_dir.x -= 1
		if Input.is_action_pressed("down"):
			input_dir.y += 1
		if Input.is_action_pressed("up"):
			input_dir.y -= 1

		if input_dir != Vector2.ZERO:
			# Нормализуем, чтобы диагональное движение не было быстрее
			input_dir = input_dir.normalized()
			velocity = input_dir * speed

			# Выбираем анимацию по доминирующей оси
			if abs(input_dir.x) > abs(input_dir.y):
				if input_dir.x > 0:
					right_move()
				else:
					left_move()
			else:
				if input_dir.y > 0:
					down_move()
				else:
					up_move()
		else:
			idle()

	move_and_slide()
	if flashlight_on:
		check_flashlight_hit()

	# Расход батареи, если фонарик включен
	if flashlight_on:
		if battery > 0:
			battery -= battery_drain_rate * delta
			battery_bar.value = battery
			if battery <= 0:
				battery = 0
				battery_bar.value = 0
				battery_empty()
		else:
			battery_empty()

func check_flashlight_hit():
	if not flashlight_on:
		return

	flashlight_ray.force_raycast_update()

	if flashlight_ray.is_colliding():
		var body = flashlight_ray.get_collider()

		if body and body.is_in_group("mob"):
			if body.has_method("apply_flashlight_stun"):
				body.apply_flashlight_stun()

func take_damage(amount: int):
	if has_node("Camera2D"):
		$Camera2D.shake(15.0)

	var final_damage = amount - armor
	if final_damage < 0:
		final_damage = 0
	current_health -= final_damage
	health_bar.value = current_health
	Global.current_health = current_health
	if current_health <= 0:
		die()

func die():
	Global.coins = 0
	Global.current_health = max_health
	Global.target_door_name = ""
	Global.has_sword = false
	Global.has_book = false
	Global.has_banka = false
	Global.has_zvetok = false
	get_tree().change_scene_to_file("res://scene/world.tscn")

func update_ui():
	if Global.has_book:
		book_icon.modulate.a = 1.0
	if Global.has_banka:
		banka_icon.modulate.a = 1.0
	if Global.has_zvetok:
		zvetok_icon.modulate.a = 1.0
	coin_label.text = "Coins: " + str(coins)
	if has_sword:
		sword_icon.modulate.a = 1.0
	Global.coins = coins
	Global.has_sword = has_sword

func up_move():
	anim.play("Up")
	velocity.y = -speed
	idle_dir = UP

func down_move():
	anim.play("Down")
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

func update_flashlight_angle():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	flashlight_pivot.rotation = dir.angle() - PI/2

func battery_empty():
	flashlight_on = false
	flashlight_sprite.visible = false
	get_tree().change_scene_to_file("res://scene/world.tscn")

func idle():
	velocity = Vector2.ZERO
	match idle_dir:
		DOWN: anim.play("Idle_down")
		UP: anim.play("Idle_up")
		LEFT:
			anim.flip_h = true
			anim.play("Idle_front")
		RIGHT:
			anim.flip_h = false
			anim.play("Idle_front")

# Диалог
func start_dialogue(lines: Array):
	dialogue_lines = lines
	current_line_index = 0
	show_current_line()

func show_current_line():
	if current_line_index < dialogue_lines.size():
		dialogue_text.text = dialogue_lines[current_line_index]
		dialogue_box.visible = true
	else:
		hide_dialogue()

func hide_dialogue():
	dialogue_box.visible = false
	dialogue_lines = []
	current_line_index = 0

func show_dialogue(text_to_show: String):
	start_dialogue([text_to_show])
