extends Node2D
# Hidden collectible. Lives at a tile centre. Starts hidden; revealed when
# its tile is mowed. Emits `collected` when the player overlaps it after
# reveal.

signal collected

const RADIUS: float = 14.0
const COLOR_CORE := Color(1.0, 0.85, 0.2)
const COLOR_GLOW := Color(1.0, 1.0, 0.6, 0.35)

var row: int = 0
var col: int = 0
var revealed: bool = false
var taken: bool = false

var _pulse_t: float = 0.0

func _ready() -> void:
	visible = false
	scale = Vector2.ZERO

func reveal() -> void:
	if revealed:
		return
	revealed = true
	visible = true
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35)

func try_collect(player_pos: Vector2, player_radius: float) -> bool:
	if taken or not revealed:
		return false
	if position.distance_to(player_pos) < player_radius + RADIUS * 0.5:
		taken = true
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tw.tween_callback(func(): visible = false)
		emit_signal("collected")
		return true
	return false

func _process(delta: float) -> void:
	if revealed and not taken:
		_pulse_t += delta
		queue_redraw()

func _draw() -> void:
	if not revealed or taken:
		return
	var pulse: float = 1.0 + 0.15 * sin(_pulse_t * 4.0)
	draw_circle(Vector2.ZERO, RADIUS * 1.8 * pulse, COLOR_GLOW)
	draw_circle(Vector2.ZERO, RADIUS, COLOR_CORE)
