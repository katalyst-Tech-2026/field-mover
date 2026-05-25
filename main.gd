extends Node2D

var _initialized: bool = false

func _ready():
	get_tree().root.size_changed.connect(_on_resize)
	_on_resize()

func _on_resize():
	var vp = get_viewport_rect().size
	if not _initialized:
		$Player.position = vp / 2.0
		_initialized = true
	queue_redraw()

func _draw():
	var vp = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vp), Color(0.08, 0.08, 0.12))
