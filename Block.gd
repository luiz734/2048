extends Node2D

var _animator: Tween

signal reached_other

func _ready():
	assert(_animator, "Missing animator on block %s" % [name])
func get_type():
	return $Label.text

func set_type(type):
	$Label.text = str(type)

func disapear():
	queue_free()

func move_to(new_pos: Vector2) -> void:
	_animator.interpolate_property(self, "position", position, new_pos, .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animator.start()

func move_and_disapear(new_pos: Vector2) -> void:
	_animator.interpolate_property(self, "position", position, new_pos, .1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animator.start()
	yield(_animator, "tween_completed")
	emit_signal("reached_other")
	disapear()

func double_type():
	set_type(2 * int(get_type()))

