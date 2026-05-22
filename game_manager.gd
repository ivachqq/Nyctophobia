extends Node

var battery := 100.0   # максимальный заряд
var max_battery := 100.0

func use_battery(amount: float) -> void:
	battery -= amount
	if battery < 0:
		battery = 0
