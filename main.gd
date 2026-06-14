extends Node2D

const TILE_SIZE   = 40
const COLOR_UNCUT = Color(0.15, 0.55, 0.15)       # green grass
const COLOR_CUT   = Color(0.65, 0.50, 0.25)       # mowed dirt/tan
const COLOR_LINE  = Color(0.0, 0.0, 0.0, 0.08)    # subtle grid lines

var _initialized: bool = false
var _cols: int = 0
var _rows: int = 0
var _tiles: Array = []   # _tiles[row][col] = bool  (true = mowed)

func _ready():
	get_tree().root.size_changed.connect(_on_resize)
	_on_resize()

func _on_resize():
	var vp = get_viewport_rect().size
	if not _initialized:
		$Player.position = vp / 2.0
		_initialized = true
	_build_grid(vp)
	queue_redraw()

func _build_grid(vp: Vector2):
	_cols = int(ceil(vp.x / TILE_SIZE))
	_rows = int(ceil(vp.y / TILE_SIZE))
	_tiles = []
	for r in range(_rows):
		var row: Array = []
		row.resize(_cols)
		row.fill(false)
		_tiles.append(row)

func _process(_delta):
	var player = $Player
	var px: float = player.position.x
	var py: float = player.position.y
	var pr: float = player.RADIUS

	var col_min: int = max(0, int((px - pr) / TILE_SIZE))
	var col_max: int = min(_cols - 1, int((px + pr) / TILE_SIZE))
	var row_min: int = max(0, int((py - pr) / TILE_SIZE))
	var row_max: int = min(_rows - 1, int((py + pr) / TILE_SIZE))

	var changed := false
	for r in range(row_min, row_max + 1):
		for c in range(col_min, col_max + 1):
			if _tiles[r][c]:
				continue
			# Circle-vs-AABB overlap check
			var tx := float(c * TILE_SIZE)
			var ty := float(r * TILE_SIZE)
			var nx: float = clamp(px, tx, tx + TILE_SIZE)
			var ny: float = clamp(py, ty, ty + TILE_SIZE)
			if (px - nx) * (px - nx) + (py - ny) * (py - ny) < pr * pr:
				_tiles[r][c] = true
				changed = true

	if changed:
		queue_redraw()

func _draw():
	for r in range(_rows):
		for c in range(_cols):
			var rect := Rect2(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, COLOR_CUT if _tiles[r][c] else COLOR_UNCUT)
			draw_rect(rect, COLOR_LINE, false, 1.0)
