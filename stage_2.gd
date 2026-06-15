extends Node2D
# Placeholder Stage 2 — proves the transition works. Replace with real
# gameplay later.

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.1, 0.15)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "Stage 2\n— coming soon —"
	label.add_theme_font_size_override("font_size", 48)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	layer.add_child(label)

	var back := Button.new()
	back.text = "Back to Stage 1"
	back.position = Vector2(40, 80)
	back.custom_minimum_size = Vector2(240, 60)
	back.pressed.connect(func(): GameState.goto_stage(1))
	layer.add_child(back)
