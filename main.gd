extends Node2D
# Stage 1 — familiarisation. Mow the field, discover a hidden collectible,
# reach 50% mowed, then enter the portal that appears to advance to Stage 2.

const TILE_SIZE   := 40
const COLOR_UNCUT := Color(0.15, 0.55, 0.15)       # green grass
const COLOR_CUT   := Color(0.65, 0.50, 0.25)       # mowed dirt/tan
const COLOR_LINE  := Color(0.0, 0.0, 0.0, 0.08)    # subtle grid lines

const UNLOCK_MOWED_PCT := 0.50
const SPAWN_EXCLUSION_PX := 200.0

const CollectibleScript := preload("res://collectible.gd")
const PortalScript      := preload("res://portal.gd")

var _initialized: bool = false
var _cols: int = 0
var _rows: int = 0
var _tiles: Array = []          # _tiles[row][col] = bool  (true = mowed)
var _mowed_count: int = 0
var _total_tiles: int = 0

var _collectible: Node2D = null
var _portal: Node2D = null
var _hud_label: Label = null

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_resize)
	_build_hud()
	_on_resize()

func _on_resize() -> void:
	var vp := get_viewport_rect().size
	if not _initialized:
		$Player.position = vp / 2.0
		_initialized = true
	_build_grid(vp)
	_spawn_collectible(vp)
	# Resizing wipes mowing progress. TODO: preserve across rotation if needed.
	if _portal:
		_portal.queue_free()
		_portal = null
	queue_redraw()
	_update_hud()

func _build_grid(vp: Vector2) -> void:
	_cols = int(ceil(vp.x / TILE_SIZE))
	_rows = int(ceil(vp.y / TILE_SIZE))
	_tiles = []
	for r in range(_rows):
		var row: Array = []
		row.resize(_cols)
		row.fill(false)
		_tiles.append(row)
	_total_tiles = _cols * _rows
	_mowed_count = 0

func _spawn_collectible(vp: Vector2) -> void:
	if _collectible:
		_collectible.queue_free()
		_collectible = null

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var player_pos: Vector2 = $Player.position
	var c: int = 0
	var r: int = 0
	for attempt in range(64):
		c = rng.randi_range(1, max(1, _cols - 2))
		r = rng.randi_range(1, max(1, _rows - 2))
		var world := Vector2((c + 0.5) * TILE_SIZE, (r + 0.5) * TILE_SIZE)
		if world.distance_to(player_pos) >= SPAWN_EXCLUSION_PX:
			break

	_collectible = CollectibleScript.new()
	_collectible.row = r
	_collectible.col = c
	_collectible.position = Vector2((c + 0.5) * TILE_SIZE, (r + 0.5) * TILE_SIZE)
	_collectible.collected.connect(_on_collectible_collected)
	add_child(_collectible)

func _process(_delta: float) -> void:
	var player := $Player
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
			var tx: float = float(c * TILE_SIZE)
			var ty: float = float(r * TILE_SIZE)
			var nx: float = clamp(px, tx, tx + TILE_SIZE)
			var ny: float = clamp(py, ty, ty + TILE_SIZE)
			if (px - nx) * (px - nx) + (py - ny) * (py - ny) < pr * pr:
				_tiles[r][c] = true
				_mowed_count += 1
				changed = true

	if _collectible and not _collectible.revealed:
		if _tiles[_collectible.row][_collectible.col]:
			_collectible.reveal()

	if _collectible and _collectible.revealed:
		_collectible.try_collect(player.position, pr)

	_maybe_spawn_portal()

	if _portal:
		_portal.try_enter(player.position, pr)

	if changed:
		queue_redraw()
		_update_hud()

func _maybe_spawn_portal() -> void:
	if _portal:
		return
	if _collectible == null or not _collectible.taken:
		return
	if _total_tiles == 0:
		return
	if float(_mowed_count) / float(_total_tiles) < UNLOCK_MOWED_PCT:
		return

	var vp := get_viewport_rect().size
	var player_pos: Vector2 = $Player.position
	# Opposite corner from player, with a margin.
	var margin: float = 80.0
	var target := Vector2(
		margin if player_pos.x > vp.x * 0.5 else vp.x - margin,
		margin if player_pos.y > vp.y * 0.5 else vp.y - margin
	)
	_portal = PortalScript.new()
	_portal.position = target
	_portal.entered.connect(_on_portal_entered)
	add_child(_portal)
	_update_hud()

func _on_collectible_collected() -> void:
	GameState.unlock("stage_1_collectible")
	_update_hud()

func _on_portal_entered() -> void:
	GameState.goto_stage(2)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_label = Label.new()
	_hud_label.add_theme_font_size_override("font_size", 22)
	_hud_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	_hud_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_hud_label.add_theme_constant_override("outline_size", 4)
	_hud_label.position = Vector2(16, 16)
	layer.add_child(_hud_label)

func _update_hud() -> void:
	if _hud_label == null:
		return
	var pct: int = 0
	if _total_tiles > 0:
		pct = int(round(100.0 * float(_mowed_count) / float(_total_tiles)))
	var item_mark: String = "✓" if (_collectible and _collectible.taken) else "✗"
	var portal_mark: String = "  →  Portal open!" if _portal else ""
	_hud_label.text = "Mowed: %d%%   Item: %s%s" % [pct, item_mark, portal_mark]

func _draw() -> void:
	for r in range(_rows):
		for c in range(_cols):
			var rect := Rect2(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, COLOR_CUT if _tiles[r][c] else COLOR_UNCUT)
			draw_rect(rect, COLOR_LINE, false, 1.0)
