extends CharacterBody2D

@onready var book_icon = $CanvasLayer/BookIcon

enum { DOWN, UP, LEFT, RIGHT }
@onready var health_bar = $CanvasLayer/HealthBar
@onready var anim = $AnimatedSprite2D
var speed = 450
var idle_dir = DOWN
var max_health = 3
var current_health = 3
var armor = 0

var is_attacking = false

var has_sword = false
var coins = 0

@onready var sword_icon = $CanvasLayer/SwordIcon
@onready var coin_label = $CanvasLayer/CoinLabel


func _input(event: InputEvent) -> void:
	if dialogue_box.visible:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			current_line_index += 1
			show_current_line()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("attack") and has_sword:
		attack()
		
func attack():
	if has_sword and not is_attacking:
		is_attacking = true
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
		
func _ready():
	coins = Global.coins
	has_sword = Global.has_sword
	current_health = Global.current_health
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	update_ui()
	
	if Global.has_book:
		book_icon.modulate.a = 1.0
	

	if Global.target_door_name != "":
		var spawn_point = get_tree().current_scene.find_child(Global.target_door_name, true, false)
		if spawn_point:
			global_position = spawn_point.global_position
			
func take_damage(amount: int):
	health_bar.max_value = max_health
	health_bar.value = current_health

	$Camera2D.shake(15.0)
	var final_damage = amount - armor
	if final_damage < 0: final_damage = 0
	
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
	get_tree().change_scene_to_file("res://scene/world.tscn")

func update_ui():
	
	if Global.has_book:
		book_icon.modulate.a = 1.0
	coin_label.text = "Coins: " + str(coins)
	if has_sword:
		sword_icon.modulate.a = 1.0
	
	Global.coins = coins
	Global.has_sword = has_sword
	
func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO 
	if not is_attacking:
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
			

var dialogue_lines: Array = []
var current_line_index: int = 0

@onready var dialogue_box = $CanvasLayer/DialogueBox
@onready var dialogue_text = $CanvasLayer/DialogueBox/DialogueText

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
