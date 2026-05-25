extends CharacterBody2D

const RADIUS = 30.0
const CIRCLE_COLOR = Color(0.2, 0.7, 1.0)

var speed = 400.0
var acceleration = 1200.0
var friction = 900.0

var touch_active: bool = false
var touch_target: Vector2 = Vector2.ZERO

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, RADIUS, CIRCLE_COLOR)
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 64, Color(1.0, 1.0, 1.0, 0.25), 2.0)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_active = true
			touch_target = event.position
		else:
			touch_active = false
	elif event is InputEventScreenDrag:
		touch_active = true
		touch_target = event.position

func _physics_process(delta):
	var vp = get_viewport_rect().size
	var dir = Vector2.ZERO

	if touch_active:
		var diff = touch_target - position
		if diff.length() > 8.0:
			dir = diff.normalized()
	else:
		dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
	_bounce_boundaries(vp)

func _bounce_boundaries(vp: Vector2):
	if position.x < RADIUS:
		position.x = RADIUS
		velocity.x = abs(velocity.x)
	elif position.x > vp.x - RADIUS:
		position.x = vp.x - RADIUS
		velocity.x = -abs(velocity.x)

	if position.y < RADIUS:
		position.y = RADIUS
		velocity.y = abs(velocity.y)
	elif position.y > vp.y - RADIUS:
		position.y = vp.y - RADIUS
		velocity.y = -abs(velocity.y)
