extends Area2D

var has_talked = false
var coins = 0
var talked = 0
func _on_body_entered(body: Node2D) -> void:

	if body.name.to_lower() == "player":
		print(body.coins)
		if Global.talked == 0 or (Global.talked == 1 and Global.coins < 5):
			var story = [
				"Привет! Ого, как ты тут оказался?\nРедко кто заходит в наш город\n(ЛКМ чтобы продолжить)",
				"Ты заблудился?",
				"Хорошо,\n я помогу тебе выбраться из нашего города.",
				"Но тебе нужно помочь мне.",
				"В нашем городе где-то лежит меч,\n с ним ты сможешь атаковать врагов.",
				"А с врагов падают монеты.",
				"Собери 5 монет, тогда я помогу тебе.",
				"Но учти: после смерти ты потеряешь всё:\nи меч, и монеты. Будь аккуратен!",
				"Меч появляется каждый раз в новых местах.",
				"Подсказка: атаковать на ЛКМ."
			]
			Global.talked = 1
			body.start_dialogue(story)
		
		elif Global.talked == 1 and Global.coins >= 5:
			var story = [
				"Уже собрал???",
				"Хорошо. Сейчас скажу,\n где находится первая деталь,\n необходимая для твоего спасения.",
				"Найди справочник по нашему городу.",
				"Подсказка: это ярко-красная книга.",
				"Лежит в библиотке",
		]
			body.start_dialogue(story)
			body.coins = body.coins-5
			body.update_ui()
			Global.talked = 2

		elif Global.talked == 2 and Global.has_book == false:
			var story = [
				"Напоминаю: нужна книга.",
				"Красная!",
		]
			body.start_dialogue(story)

		elif Global.talked == 2 and Global.has_book == true:
			var story = [
				"Молодец, у тебя теперь есть первая деталь,\n необходимая для твоего спасения.",
				"Но то, где находится следующая, \nя скажу тебе за 5 монет.",
				"Поэтому в путь!"
		]
			Global.talked = 3
			body.start_dialogue(story)
		
		elif Global.talked == 3 and Global.coins < 5:
			var story = [
				"5 монет надо.",
		]
			body.start_dialogue(story)

		elif Global.talked == 3 and Global.coins >= 5:
			var story = [
				"О, молодец! \nСледующая деталь — это цветок, найди его.",
				"Подсказка: это куст розы."
		]
			body.start_dialogue(story)
			body.coins = 0
			body.update_ui()
			Global.talked = 4
		
		elif Global.talked == 4 and Global.has_zvetok == false:
			var story = [
				"Я жду куст розы. Без него дело не пойдет.",
		]
			body.start_dialogue(story)
		
		elif Global.talked == 4 and Global.has_zvetok == true:
			var story = [
				"Какая красота... Цветок у нас.",
				"Осталась последняя деталь — \nтайная склянка с эссенцией города.",
				"Но\n за красивые глаза я информацию не раздаю.\n Ещё 5 монет, и мы в расчете."
		]
			Global.talked = 5
			body.start_dialogue(story)

		elif Global.talked == 5 and Global.coins < 5:
			var story = [
				"Принеси еще 5 монет, и я скажу, где искать банку.",
			]
			body.start_dialogue(story)
		
		elif Global.talked == 5 and Global.coins >= 5:
			var story = [
				"Отлично! Склянка спрятана в школе.",
				"На столе стоит две банки, \nта что меньше - твоя",
				"Найди её и возвращайся. Это последний шаг!"
			]
			body.start_dialogue(story)
			body.coins = 0
			body.update_ui()
			Global.talked = 6

		elif Global.talked == 6 and Global.has_banka == false:
			var story = [
				"Осталось принести только банку.\n Поторопись!",
			]
			body.start_dialogue(story)
		
		elif Global.talked == 6 and Global.has_banka == true:
			var story = [
				"Невероятно... \nТы собрал всё: и книгу, и цветок, и банку!",
				"Я держу своё слово. \nДревний ритуал завершен, и путь из города открыт.",
				"Ты свободен! Спасибо тебе..."
			]
			body.start_dialogue(story)
			win_game()
			
			
func _on_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		body.hide_dialogue()
		
func win_game():
	await get_tree().create_timer(5.0).timeout
	Global.talked = 0
	Global.coins = 0
	Global.has_sword = false
	Global.has_book = false
	Global.has_zvetok = false
	Global.has_banka = false

	get_tree().change_scene_to_file("res://scene/win.tscn")
