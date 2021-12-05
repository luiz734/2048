extends Node2D

export var _size:int = 5
export(Array, Color) var _colors: Array = []

var _blocks = []
var Block = preload("res://Block.tscn")
const BLOCK_MARGIN = 20
const BLOCK_SIZE = 64


var _ignored_blocks

func _ready():
	_init_blocks()
	_ignored_blocks = []

func _input(event):
	if event.is_action_pressed("ui_up"):
		_handle_action(Vector2.UP)
	if event.is_action_pressed("ui_right"):
		_handle_action(Vector2.RIGHT)
	if event.is_action_pressed("ui_down"):
		_handle_action(Vector2.DOWN)
	if event.is_action_pressed("ui_left"):
		_handle_action(Vector2.LEFT)

func _handle_action(direction):
	if $Tween.is_active():
		return
	var before_move = _blocks.duplicate()
	_move_blocks(direction)
	if not before_move == _blocks:
		_add_random_block()
	_ignored_blocks.clear()
	
func _move_blocks(direction):
	for index in range(_size * _size):
		if not _is_index_valid(index) or not _blocks[index]:
			continue
		var row = _calc_row(index)
		var col = _calc_col(index)
		var next_pos = Vector2(col + direction.x, row + direction.y)
		var next_index = int(_calc_index(next_pos.y, next_pos.x))
		
		var same_row = row == _calc_row(next_index) and direction.y == 0
		var same_col = col == _calc_col(next_index) and direction.x == 0
		
		if not same_row and not same_col:
			continue
		if not _is_index_valid(next_index):
			continue
			
		if _blocks[next_index]:
			var same_type = _is_same_type(_blocks[index], _blocks[next_index])
			var index_not_ignored = not _ignored_blocks.has(_blocks[index])
			var next_index_not_ignored = not _ignored_blocks.has(_blocks[next_index])
			
			if same_type and index_not_ignored and next_index_not_ignored:
				var pos = _calc_screen_position(next_index)
				_blocks[index].connect("reached_other", _blocks[next_index], "double_type")
				_blocks[index].move_and_disapear(pos)
				_blocks[index] = null
#				_blocks[next_index].set_type(2 * int(_blocks[next_index].get_type()))
				_ignored_blocks.push_back(_blocks[next_index])
				_move_blocks(direction)
		else:
			var pos = _calc_screen_position(next_index)
			_blocks[index].move_to(pos)
			_blocks[next_index] = _blocks[index]
			_blocks[index] = null
#			_update_screen_pos(_blocks[next_index], next_index)
			_move_blocks(direction)

func _update_screen_pos(block, new_index):
	var pos = _calc_screen_position(new_index)
	block.position = pos
			
func _is_index_valid(index):
	return index >= 0 and index < _size * _size
func _calc_row(index):
	return index / _size

func _calc_col(index):
	return index % _size

func _calc_index(row, col):
	return _size * row + col

func _is_same_type(block_a, block_b):
	return block_a.get_type() == block_b.get_type()

func _calc_screen_position(index):
	var pos = Vector2.ZERO
	var row = _calc_row(index)
	var col = _calc_col(index)
	pos.y = row * (BLOCK_MARGIN + BLOCK_SIZE)
	pos.x = col * (BLOCK_MARGIN + BLOCK_SIZE)
	return pos

func _get_index(block):
	return _blocks.find(block)

func _add_random_block():
	if $Tween.is_active():
		yield($Tween, "tween_all_completed")
	if _blocks.count(null) == 0:
		print("No more movements")
		return
	var rand_index = randi() % (_size * _size)
	while _blocks[rand_index]:
		rand_index = randi() % (_size * _size)
	
	var rand_type = 2
	if randf() < 0.25:
		rand_type = 4
#	var rand_type = str(type)
	
	var block = Block.instance()
	block.position = _calc_screen_position(rand_index)
	block.name = "block %s-%s (%s)" % [_calc_row(rand_index), _calc_col(rand_index), rand_index]
	block._animator = $Tween
	block._colors = _colors
	block.set_type(rand_type)
	add_child(block)
	_blocks[rand_index] = block
	
	
func _init_blocks():
	for i in range(_size * _size):
		var rect_bg = ColorRect.new()
		rect_bg.rect_size = Vector2(BLOCK_SIZE, BLOCK_SIZE)
		rect_bg.rect_position = _calc_screen_position(i) + Vector2(BLOCK_MARGIN, BLOCK_MARGIN)
		rect_bg.color = Color8(77, 80, 64, 96)
		$Background.add_child(rect_bg)
		_blocks.push_back(null)
	_add_random_block()
	_add_random_block()
#	_add_random_block(2)
#	_add_random_block(16)
#	_add_random_block(128)
#	_add_random_block(1024)

			

