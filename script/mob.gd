extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
var speed = 100
var player = null
var coin_scene = preload("res://scene/coins.tscn")
var target_to_attack = null
var can_attack = true
var hp = 3
@onready var hp_bar = $MobHealthBar

# Для ослепления фонариком
var is_stunned = false
var stun_timer = 0.0

func _ready():
 add_to_group("mob")

func take_damage(amount):
 hp -= amount
 hp_bar.value = hp
 if hp <= 0:
  die()


func _ready() -> void:
	hp_bar.max_value = 3
	hp_bar.value = hp

func die():
 spawn_coin()
 queue_free()

func spawn_coin():
 var coin = coin_scene.instantiate()
 get_parent().add_child(coin)
 coin.global_position = global_position

# ИСПРАВЛЕННАЯ ФУНКЦИЯ ОСЛЕПЛЕНИЯ
func apply_flashlight_stun():
 # Если моб УЖЕ ослеплен, мы выходим из функции, 
 # чтобы не сбрасывать таймер обратно на 4.0 каждый кадр
 if is_stunned:
  return
  
 is_stunned = true
 stun_timer = 4.0
 anim.play("Idle")

func _physics_process(delta: float) -> void:
 # Если ослеплён — стоим на месте и отсчитываем время
 if is_stunned:
  stun_timer -= delta
  if stun_timer <= 0:
   is_stunned = false
  velocity = Vector2.ZERO
  move_and_slide()
  return  # выходим, не двигаемся и не атакуем
 
 # Обычное поведение (погоня)
 if player:
  var dir = (player.position - position).normalized()
  velocity = dir * speed
  move_and_slide()
  anim.play("walk")
  anim.flip_h = dir.x < 0
 else:
  velocity = Vector2(0, 0)
  anim.play("Idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
 if body.name == "player":
  player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
 if body.name == "player":
  player = null

func _on_area_2d_2_body_entered(body: Node2D) -> void:
 if body.name == "player":
  target_to_attack = body
  check_attack()

func _on_area_2d_2_body_exited(body: Node2D) -> void:
 if body == target_to_attack:
  target_to_attack = null

func _on_timer_timeout() -> void:
 can_attack = true
 check_attack()

func check_attack():
 if target_to_attack and can_attack:
  perform_attack()

func perform_attack():
 can_attack = false
 target_to_attack.take_damage(1) 
 $Timer.start()
