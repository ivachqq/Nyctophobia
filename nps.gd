extends Area2D

var has_talked = false
var coins = 0
var talked = 0

func _on_body_entered(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		print(coins)
		# Первый разговор или повтор, пока не собрал 5 монет
		if (Global.coins < 5) and (Global.talked == 0 or Global.talked == 1):
			var story = [
				"Привет! Ого, как ты тут оказался?\nРедко кто заходит в наш город\n(ЛКМ чтобы продолжить)",
				"Ты заблудился?",
				"Хорошо,\nя помогу тебе выбраться из нашего города",
				"Но тебе нужно помочь мне",
				"В нашем городе где-то лежит меч,\nс ним ты сможешь атаковать монстров",
				"А с монстров падают монеты",
				"Собери 5 монет,\nтогда я помогу тебе",
				"Но учти, после смерти, ты потеряешь все:\nи меч, и монеты, будь аккуратен",
				"Меч появляется каждый раз в новых местах",
				"Подсказка: атаковать ЛКМ"
			]
			Global.talked = 1
			body.start_dialogue(story)
		# Игрок принёс 5 монет и ещё не получал награду
		elif Global.coins >= 5 and Global.talked == 1:
			var story = [
				"Уже собрал???",
				"Хорошо, сейчас скажу где находится первая деталь,\nнеобходимая для твоего спасения",
				"Найди справочник по нашему городу",
				"Подсказка: это ярко красная книга"
			]
			body.start_dialogue(story)
			body.coins = body.coins - 5   # списываем 5 монет
			body.update_ui()
			Global.talked = 2
		# После получения задания найти книгу, но книга ещё не найдена
		elif Global.talked == 2 and Global.has_book == false:
			var story = [
				"Напоминаю нужна книга",
				"Красная"
			]
			body.start_dialogue(story)
		# Книга найдена
		elif Global.talked == 2 and Global.has_book == true:
			var story = [
				"Молодец, у тебя теперь есть первая деталь,\nнеобходимая для твоего спасения",
				"Но то, где находится следующая, я скажу тебе\nза 5 монет",
				"Поэтому в путь"
			]
			Global.talked = 3
			body.start_dialogue(story)
		# Следующее задание, но не хватает монет
		elif Global.talked == 3 and Global.coins < 5:
			var story = [
				"5 монет надо"
			]
			body.start_dialogue(story)
		# Хватает монет для следующей подсказки
		elif Global.talked == 3 and Global.coins >= 5:
			var story = [
				"О молодец, следующая деталь это цветок, найти его",
				"Подсказка: он ярко фиолетовый"
			]
			body.start_dialogue(story)
			body.coins = body.coins - 5   # списываем монеты (если нужно)
			body.update_ui()
			# Здесь можно перевести на следующий этап, например Global.talked = 4

func _on_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		body.hide_dialogue()
