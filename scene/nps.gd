extends Area2D

var has_talked = false

func _on_body_entered(body: Node2D) -> void:

	if body.name.to_lower() == "player":
		if not has_talked:
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
				"Собери 20 монет,
				тогда может я помогу тебе"
			]
			body.start_dialogue(story)
			has_talked = true 
		else:
			var story = [
				"Уже собрал???",
				"Хорошо, но есть еще одна просьба",
				"Найди в библиотеке справочник по мобам",
				"Он будет отличаться от остальных книг"
			]
			body.start_dialogue(story)

func _on_body_exited(body: Node2D) -> void:
	if body.name.to_lower() == "player":
		body.hide_dialogue()
