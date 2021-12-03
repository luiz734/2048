extends Node2D

export var _size:int = 4
var _blocks = []
var Block = preload("res://Block.tscn")
const BLOCK_MARGIN = 20
const BLOCK_SIZE = 64

func _ready():
	_init_blocks()

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
		
		if not _is_index_valid(next_index) or _blocks[next_index]:
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
	return block_a.get_node("Label").text == block_a.get_node("Label").text

func _calc_screen_position(index):
	var pos = Vector2.ZERO
	var row = _calc_row(index)
	var col = _calc_col(index)
	pos.y = row * (BLOCK_MARGIN + BLOCK_SIZE)
	pos.x = col * (BLOCK_MARGIN + BLOCK_SIZE)
	return pos

func _get_index(block):
	return _blocks.find(block)

func _init_blocks():
	for i in range(_size * _size):
		var block = null
		if i % 3 == 0:
			block = Block.instance()
			block.position = _calc_screen_position(i)
			block.name = "block %s-%s (%s)" % [_calc_row(i), _calc_col(i), i]
			add_child(block)
		_blocks.push_back(block)
			

