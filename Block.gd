extends Node2D

func get_type():
	return $Label.text

func set_type(type):
	$Label.text = str(type)
