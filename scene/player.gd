extends CharacterBody2D

enum { DOWN, UP, LEFT, RIGHT }

@onready var anim = $AnimatedSprite2D
var speed = 150
var idle_dir = DOWN


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
			
