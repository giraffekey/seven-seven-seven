extends Node2D

var block = [null, null]
var next = [null, null]
var col = 0
var row = 0
var orientation = 0
var score = 0
var next_level = 500
var level = 1
var counts = [0, 0, 0, 0, 0, 0, 0, 0]
var fast_dropping = false

func _ready() -> void:
	randomize()
	gen_next()
	spawn_block()
	update_labels()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left") and not $FallTimer.is_stopped():
		move_left()
		$MoveLeftTimer.start()

	if Input.is_action_just_released("left"):
		$MoveLeftTimer.stop()

	if Input.is_action_just_pressed("right") and not $FallTimer.is_stopped():
		move_right()
		$MoveRightTimer.start()

	if Input.is_action_just_released("right"):
		$MoveRightTimer.stop()

	if Input.is_action_just_pressed("rotate") and not $FallTimer.is_stopped():
		rotate_block()
		$RotateTimer.start()

	if Input.is_action_just_released("rotate"):
		$RotateTimer.stop()

	if Input.is_action_just_pressed("accelerate") and not $FallTimer.is_stopped():
		$FallTimer.start(min($FallTimer.time_left, 0.25 / ((level + 1) / 2.0)))

	if Input.is_action_pressed("accelerate"):
		$FallTimer.wait_time = 0.25 / ((level + 1) / 2.0)
	else:
		$FallTimer.wait_time = 1.0 / ((level + 1) / 2.0)

	if Input.is_action_just_pressed("fast_drop") and not $FallTimer.is_stopped():
		fast_drop()
		$FastDropTimer.start()
		fast_dropping = true

	if Input.is_action_just_released("fast_drop"):
		$FastDropTimer.stop()
		fast_dropping = false

func _on_fall_timer_timeout() -> void:
	fall()

func _on_move_left_timer_timeout() -> void:
	move_left()

func _on_move_right_timer_timeout() -> void:
	move_right()

func _on_rotate_timer_timeout() -> void:
	rotate_block()

func _on_fast_drop_timer_timeout() -> void:
	fast_drop()

func fall() -> void:
	var old_cells = erase_block()
	row = min(row + 1, 19)
	var new_cells = block_cells()

	var coords1 = $BlockLayer.get_cell_atlas_coords(new_cells[0])
	var coords2 = $BlockLayer.get_cell_atlas_coords(new_cells[1])
	if coords1 != Vector2i(-1, -1) or coords2 != Vector2i(-1, -1):
		new_cells = old_cells

	$BlockLayer.set_cell(new_cells[0], 0, Vector2i(block[0], 0))
	$BlockLayer.set_cell(new_cells[1], 0, Vector2i(block[1], 0))

	if new_cells == old_cells:
		await clear_blocks()
		spawn_block()
		update_labels()

func move_left() -> void:
	var old_cells = erase_block()
	col = max(col - 1, 0)
	var new_cells = block_cells()

	var coords1 = $BlockLayer.get_cell_atlas_coords(new_cells[0])
	var coords2 = $BlockLayer.get_cell_atlas_coords(new_cells[1])
	if coords1 != Vector2i(-1, -1) or coords2 != Vector2i(-1, -1):
		new_cells = old_cells
		col = min(col + 1, 9)

	$BlockLayer.set_cell(new_cells[0], 0, Vector2i(block[0], 0))
	$BlockLayer.set_cell(new_cells[1], 0, Vector2i(block[1], 0))

func move_right() -> void:
	var old_cells = erase_block()
	col = min(col + 1, 9)
	var new_cells = block_cells()

	var coords1 = $BlockLayer.get_cell_atlas_coords(new_cells[0])
	var coords2 = $BlockLayer.get_cell_atlas_coords(new_cells[1])
	if coords1 != Vector2i(-1, -1) or coords2 != Vector2i(-1, -1):
		new_cells = old_cells
		col = max(col - 1, 0)

	$BlockLayer.set_cell(new_cells[0], 0, Vector2i(block[0], 0))
	$BlockLayer.set_cell(new_cells[1], 0, Vector2i(block[1], 0))

func rotate_block() -> void:
	var old_cells = erase_block()
	orientation += 1
	if orientation > 3: orientation = 0
	var new_cells = block_cells()

	var coords1 = $BlockLayer.get_cell_atlas_coords(new_cells[0])
	var coords2 = $BlockLayer.get_cell_atlas_coords(new_cells[1])
	if coords1 != Vector2i(-1, -1) or coords2 != Vector2i(-1, -1):
		new_cells = old_cells
		orientation -= 1
		if orientation < 0: orientation = 3

	$BlockLayer.set_cell(new_cells[0], 0, Vector2i(block[0], 0))
	$BlockLayer.set_cell(new_cells[1], 0, Vector2i(block[1], 0))

func fast_drop() -> void:
	if row == 0:
		await fall()
	while row > 0:
		await fall()

func block_cells() -> Array:
	var c = col
	var r = row
	match orientation:
		0:
			if c == 9: c = 8
			return [Vector2i(c, r), Vector2i(c + 1, r)]
		1:
			if r == 19: r = 18
			return [Vector2i(c, r), Vector2i(c, r + 1)]
		2:
			if c == 9: c = 8
			return [Vector2i(c + 1, r), Vector2i(c, r)]
		3:
			if r == 19: r = 18
			return [Vector2i(c, r + 1), Vector2i(c, r)]
	return []

func block_value(cell: Vector2i) -> int:
	return $BlockLayer.get_cell_atlas_coords(cell).x

func gen_next() -> void:
	var first = randi_range(0, 7)
	var nums = range(8)
	nums.remove_at(7 - first)
	var second = nums.pick_random()
	next = [first, second]

func spawn_block() -> void:
	block = next.duplicate()
	col = randi_range(0, 9)
	row = 0
	orientation = randi_range(0, 3)

	gen_next()

	var cells = block_cells()

	var coords1 = $BlockLayer.get_cell_atlas_coords(cells[0])
	var coords2 = $BlockLayer.get_cell_atlas_coords(cells[1])
	if coords1 != Vector2i(-1, -1) or coords2 != Vector2i(-1, -1):
		get_tree().reload_current_scene()
		return

	$BlockLayer.set_cell(cells[0], 0, Vector2i(block[0], 0))
	$BlockLayer.set_cell(cells[1], 0, Vector2i(block[1], 0))

	$FallTimer.start()

func erase_block() -> Array:
	var cells = block_cells()
	$BlockLayer.erase_cell(cells[0])
	$BlockLayer.erase_cell(cells[1])
	return cells

func clear_blocks():
	$FallTimer.stop()

	if fast_dropping:
		$FastDropTimer.stop()
	
	var cleared = true
	var lines = 0
	while cleared:
		cleared = false
		for c in range(10):
			for r in range(20):
				var cell = Vector2i(c, r)
				if block_value(cell) > -1:
					var row_seq = []
					var row_sum = 0
					var row_seq_found = null
					var row_sum_found = 0
					for i in range(10 - c):
						var next_cell = Vector2i(c + i, r)
						var value = block_value(next_cell)
						if value > -1:
							if len(row_seq) > 0 or value > 0:
								row_seq.append(next_cell)
								row_sum += value
							if row_sum > 0 and value > 0 and row_sum % 7 == 0 and len(row_seq) >= 2:
								row_seq_found = row_seq.duplicate()
								row_sum_found = row_sum
						else:
							break

					if row_seq_found and len(row_seq_found) == 2 and row_sum_found == 14:
						row_seq_found = null

					var col_seq = []
					var col_sum = 0
					var col_seq_found = null
					var col_sum_found = 0
					for i in range(20 - r):
						var next_cell = Vector2i(c, r + i)
						var value = block_value(next_cell)
						if value > -1:
							if len(col_seq) > 0 or value > 0:
								col_seq.append(next_cell)
								col_sum += value
							if col_sum > 0 and value > 0 and col_sum % 7 == 0 and len(col_seq) >= 2:
								col_seq_found = col_seq.duplicate()
								col_sum_found = col_sum
						else:
							break

					if col_seq_found and len(col_seq_found) == 2 and col_sum_found == 14:
						col_seq_found = null

					if row_seq_found:
						for seq_cell in row_seq_found:
							var coords = $BlockLayer.get_cell_atlas_coords(seq_cell)
							coords.y = 1
							$BlockLayer.set_cell(seq_cell, 0, coords)

						await get_tree().create_timer(0.25).timeout

						for seq_cell in row_seq_found:
							counts[block_value(seq_cell)] += 1
							$BlockLayer.erase_cell(seq_cell)

							for i in range(seq_cell.y):
								var above = seq_cell - Vector2i(0, i)
								var coords = $BlockLayer.get_cell_atlas_coords(above)
								if coords != Vector2i(-1, -1):
									$BlockLayer.set_cell(above + Vector2i(0, 1), 0, coords)
									$BlockLayer.erase_cell(above)

						var sevens = row_sum_found / 7
						if len(row_seq_found) == sevens:
							for i in range(1, sevens - 1):
								score += 1000 * i
						else:
							for i in range(1, sevens + 1):
								score += 100 * i

						score += 100 * lines
						score += 100 * max(len(row_seq_found) - 3, 0)

						cleared = true
						lines += 1
					elif col_seq_found:
						for seq_cell in col_seq_found:
							var coords = $BlockLayer.get_cell_atlas_coords(seq_cell)
							coords.y = 1
							$BlockLayer.set_cell(seq_cell, 0, coords)

						await get_tree().create_timer(0.25).timeout

						for seq_cell in col_seq_found:
							counts[block_value(seq_cell)] += 1
							$BlockLayer.erase_cell(seq_cell)

						for i in range(cell.y):
							var above = cell - Vector2i(0, i)
							var coords = $BlockLayer.get_cell_atlas_coords(above)
							if coords != Vector2i(-1, -1):
								$BlockLayer.set_cell(above + Vector2i(0, len(col_seq_found)), 0, coords)
								$BlockLayer.erase_cell(above)

						var sevens = col_sum_found / 7
						if len(col_seq_found) == sevens:
							for i in range(1, sevens - 1):
								score += 1000 * i
						else:
							for i in range(1, sevens + 1):
								score += 100 * i

						score += 100 * lines
						score += 100 * max(len(col_seq_found) - 3, 0)

						cleared = true
						lines += 1

					while score >= next_level:
						level += 1
						next_level += level * 500

					update_labels()

	$FallTimer.start()
	
	if fast_dropping:
		$FastDropTimer.start()

func update_labels() -> void:
	$UI/Score.text = "SCORE\n" + str(score)
	$UI/NextLevel.text = "NEXT LEVEL\n" + str(next_level)
	$UI/Level.text = "LEVEL\n      " + str(level)
	for i in range(8):
		get_node("UI/Blocks" + str(i)).text = str(counts[i])
	$UI/NextBlock1.frame = next[0]
	$UI/NextBlock2.frame = next[1]
