extends Node2D

export var _size:int = 4
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
		_ignored_blocks.clear()
		_add_random_block()
	if event.is_action_pressed("ui_right"):
		_handle_action(Vector2.RIGHT)
		_ignored_blocks.clear()
		_add_random_block()
	if event.is_action_pressed("ui_down"):
		_handle_action(Vector2.DOWN)
		_ignored_blocks.clear()
		_add_random_block()
	if event.is_action_pressed("ui_left"):
		_handle_action(Vector2.LEFT)
		_ignored_blocks.clear()
		_add_random_block()

func _handle_action(direction):
	var next_state = _blocks
	for index in range(_size * _size):
		if not _is_index_valid(index) or not _blocks[index]:
			continue
		var row = _calc_row(index)
		var col = _calc_col(index)
		var next_pos = Vector2(col + direction.x, row + direction.y)
		var next_index = int(_calc_index(next_pos.y, next_pos.x))
		
		var same_row = row == _calc_row(next_index)
		var same_col = col == _calc_col(next_index)
		
		if not same_row and direction.y == 0:
			continue
		if not same_col and direction.x == 0:
			continue
		if not _is_index_valid(next_index):
			continue
		if _blocks[next_index]:
			if _is_same_type(_blocks[index], _blocks[next_index]) and not _ignored_blocks.has(_blocks[index]) and not _ignored_blocks.has(_blocks[next_index]):
				_blocks[index].queue_free()
				_blocks[index] = null
				_blocks[next_index].set_type(2 * int(_blocks[next_index].get_type()))
				_ignored_blocks.push_back(_blocks[next_index])
				_handle_action(direction)
			continue
			
		_blocks[next_index] = _blocks[index]
		_blocks[index] = null
		_update_screen_pos(_blocks[next_index], next_index)
		_handle_action(direction)

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
	if _blocks.count(null) == 0:
		print("No more movements")
		return
	var rand_index = randi() % (_size * _size)
	while _blocks[rand_index]:
		rand_index = randi() % (_size * _size)
	
	var rand_type = 2
	if randf() < 0.25:
		rand_type = 4
	
	var block = Block.instance()
	block.position = _calc_screen_position(rand_index)
	block.name = "block %s-%s (%s)" % [_calc_row(rand_index), _calc_col(rand_index), rand_index]
	block.set_type(rand_type)
	add_child(block)
	_blocks[rand_index] = block
	
	
	
func _init_blocks():
	for i in range(_size * _size):
		var block = null
		if i % 2 == 0:
			block = Block.instance()
			block.position = _calc_screen_position(i)
			block.name = "block %s-%s (%s)" % [_calc_row(i), _calc_col(i), i]
			add_child(block)
		_blocks.push_back(block)
			

