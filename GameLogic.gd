extends Node2D

@export var _size:int = 5
@export var _colors: Array = [] # (Array, Color)

var _lock_input = false
var _blocks = []
var Block = preload("res://Block.tscn")
@onready var GUI = get_tree().get_root().get_node("Main/GUIArea")
const BLOCK_MARGIN = 4
const BLOCK_SIZE = 96

var _ignored_blocks

func _ready():
    assert(GUI, "Missing reference to GUI")
    reset_game()

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
    if _lock_input:
        return
    _lock_input = true
    var before_move = _blocks.duplicate()
    await _move_blocks(direction)
    if not before_move == _blocks:
        _add_random_block()
    _ignored_blocks.clear()
    # A hack. Tweens changed in godot 4. This is the easier workaround
    await get_tree().create_timer(0.1).timeout
    _lock_input = false
    
func _move_blocks(direction):
    var start = 0
    var end = _size * _size
    var step = 1
    var reverse_order = direction == Vector2.DOWN or direction == Vector2.RIGHT
    if reverse_order:
        start = _size * _size - 1
        end = -1
        step = -1
    
    for index in range(start, end, step):
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
                _blocks[index].connect("reached_other", Callable(_blocks[next_index], "double_type"))
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
    if _blocks.count(null) == 0:
        print("No more movements")
        return
    var rand_index = randi() % (_size * _size)
    while _blocks[rand_index]:
        rand_index = randi() % (_size * _size)
#	if index != -1:
#		rand_index = index
    var rand_type = 2
    if randf() < 0.2:
        rand_type = 4
#	var rand_type = str(type)
    
    var block = Block.instantiate()
    block.position = _calc_screen_position(rand_index)
    block.name = "block %s-%s (%s)" % [_calc_row(rand_index), _calc_col(rand_index), rand_index]
    block._colors = _colors
    block.set_type(rand_type)
    block.connect("point_scored", Callable(GUI, "on_point_scored"))
#	block.set_size(BLOCK_SIZE)
    $Pivot.add_child(block)
    _blocks[rand_index] = block

func reset_game():
    for block in $Pivot.get_children():
        block.queue_free()
    
    _init_blocks()
    _ignored_blocks = []
    
func _init_blocks():
    _blocks = []
    for i in range(_size * _size):
        var rect_bg = Sprite2D.new()
        _blocks.push_back(null)
    _add_random_block()
    _add_random_block()
#	_add_random_block(2)
#	_add_random_block(16)
#	_add_random_block(128)
#	_add_random_block(1024)

            

