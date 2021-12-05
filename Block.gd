extends Node2D

var _animator: Tween
var _colors: Array

signal reached_other
signal point_scored

func _ready():
	assert(_animator, "Missing animator on block %s" % [name])
	assert(_colors, "Missing color array on block %s" % [name])
	randomize()
	
func get_type():
	return $Label.text

func set_type(type):
	$Label.text = str(type)
	_update_color()
	
func move_to(new_pos: Vector2) -> void:
	_animator.interpolate_property(self, "position", position, new_pos, .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animator.start()

func move_and_disapear(new_pos: Vector2) -> void:
	_animator.interpolate_property(self, "position", position, new_pos, .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animator.start()
	yield(_animator, "tween_completed")
	emit_signal("reached_other")
	emit_signal("point_scored", int(get_type()))
	queue_free()

func double_type():
	set_type(2 * int(get_type()))

func _update_color():
#	for type in [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048]:
	var type = int(get_type())
	var exponent = int(log(type) / log(2))
	var index = floor((exponent - 1)) # /2)
	$Background.modulate = _colors[index]
	

	
	
	
