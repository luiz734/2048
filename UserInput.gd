extends Control

var current_score = 0

func on_point_scored(amount):
	current_score += amount
	$Score.text = str(current_score)


func _on_ButtonExit_pressed():
	get_tree().quit()

func _on_ButtonNewGame_pressed():
	current_score = 0
	$Score.text = str(current_score)
