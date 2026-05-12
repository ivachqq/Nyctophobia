extends CharacterBody2D

enum { DOWN, UP, LEFT, RIGHT }
@onready var health_bar = $CanvasLayer/HealthBar
@onready var anim = $AnimatedSprite2D
@onready var flashlight_sprite = $FlashLightSprite
var flashlight_on = false
var speed = 150
var idle_dir = DOWN
var max_health = 3
var current_health = 3
var armor = 0

func _ready():
	health_bar.max_value = max_health
	health_bar.value = current_health

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
	
	
	
func _physics_process(_delta: float) -> void:
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
	if flashlight_on:
		match idle_dir:
			DOWN:  flashlight_sprite.rotation = 0
			UP:    flashlight_sprite.rotation = PI
			LEFT:  flashlight_sprite.rotation = PI/2
			RIGHT: flashlight_sprite.rotation = -PI/2

func up_move():
	anim.play("Up")
	velocity.y = -speed
	idle_dir = UP
	flashlight_sprite.position.x=0.0
	flashlight_sprite.position.y=-40.0

func down_move():
	anim.play("down")
	velocity.y = speed
	idle_dir = DOWN
	flashlight_sprite.position.x=0.0
	flashlight_sprite.position.y=60.0

func left_move():
	anim.flip_h = true
	anim.play("Front")
	velocity.x = -speed
	idle_dir = LEFT
	flashlight_sprite.position.x=-45.0
	flashlight_sprite.position.y=10.0

func right_move():
	anim.flip_h = false
	anim.play("Front")
	velocity.x = speed
	idle_dir = RIGHT
	flashlight_sprite.position.x=45.0
	flashlight_sprite.position.y=10.0
	
	
func _input(event):
	if event.is_action_pressed("toggle_flashlight"):
		flashlight_on = not flashlight_on
		flashlight_sprite.visible = flashlight_on

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
			
