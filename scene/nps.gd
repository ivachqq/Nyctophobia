extends Area2D

var has_talked = false
var coins = 0
var talked = 0
func _on_body_entered(body: Node2D) -> void:

	if body.name.to_lower() == "player":
		print(coins)
		if (Global.coins < 5) and ((Global.talked == 0) or(Global.talked == 1)):
			var story = [
				"Привет! Ого, как ты тут оказался?
				Редко кто заходит а наш город
				(ЛКМ чтобы продолжить)",
				"Ты заблудился?",
				"Хорошо,
				я помогу тебе выбраться из нашего города",
				"Но тебе нужно помочь мне",
				"В нашем городе где-то лежит мечь,
				с ним ты сможешь атаковать врагов",
				"А с врагов падают монеты",
				"Собери 5 монет,
				тогда я помогу тебе",
				"но учти, после смерти,ты потеряешь все:
				и мечь и монеты, будь акуратен",
				"мечь появляется каждый раз в новых местах",
				"подсказка: атаковать ЛКМ"
			]
			Global.talked = 1
			body.start_dialogue(story)
			
		if (Global.coins >=5 and Global.talked == 1):
			var story = [
				"Уже собрал???",
				"Хорошо, Сейчас скажу где находится первая деталь,
				необходимая для твоего спасения",
				"Найди справочник по нашему городу",
				"Подсказка: это ярко красная книга",
			]
			body.start_dialogue(story)
			body.coins = 0
			body.update_ui()
			Global.talked = 2
			
		if Global.talked == 2 and Global.has_book == false:
			var story = [
				"Напоминаю нужна книга",
				"Красная",
			]
			body.start_dialogue(story)
		
		
		if (Global.talked == 2) and (Global.has_book == true):
			var story = [
				"Молодец у тебя теперь есть первая деталь,
				необходимая для твоего спасения",
				"Но то, где находится следующая, я скажу тебе
				за 5 монет",
				"Поэтому в путь",
			]
			Global.talked = 3
			body.start_dialogue(story)
			
			
			
		if (Global.talked == 3) and (Global.coins <5):
			var story = [
				"5 монет надо",
			]
			body.start_dialogue(story)
		
		if (Global.talked == 3) and (Global.coins <=5):
			var story = [
				"о молодец, следующая деталь это цветок, найти его",
				"подсказка: он ярко фиолетовый"
			]
			body.start_dialogue(story)
			body.coins = 0
			body.update_ui()
			
			
func _on_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		body.hide_dialogue()
