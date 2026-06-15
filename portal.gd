extends Node2D
# Portal that transports the player to the next stage when entered.

signal entered

const RADIUS: float = 36.0
const COLOR_RING := Color(0.4, 0.85, 1.0)
const COLOR_CORE := Color(0.1, 0.2, 0.4, 0.85)

var consumed: bool = false
var _t: float = 0.0

func _ready() -> void:
	scale = Vector2.ZERO
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.45)

func try_enter(player_pos: Vector2, player_radius: float) -> bool:
	if consumed:
		return false
	if position.distance_to(player_pos) < player_radius + RADIUS * 0.5:
		consumed = true
		emit_signal("entered")
		return true
	return false

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse: float = 1.0 + 0.08 * sin(_t * 3.0)
	# outer halo
	draw_circle(Vector2.ZERO, RADIUS * 1.6 * pulse, Color(COLOR_RING.r, COLOR_RING.g, COLOR_RING.b, 0.18))
	# core
	draw_circle(Vector2.ZERO, RADIUS, COLOR_CORE)
	# rotating rings
	for i in range(3):
		var r: float = RADIUS * (0.6 + 0.15 * i) * pulse
		var alpha: float = 0.7 - 0.18 * i
		draw_arc(Vector2.ZERO, r, _t * (1.0 + i * 0.5), _t * (1.0 + i * 0.5) + TAU * 0.7, 48, Color(COLOR_RING.r, COLOR_RING.g, COLOR_RING.b, alpha), 3.0)
