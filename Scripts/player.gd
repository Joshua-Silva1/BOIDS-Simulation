extends KinematicBody2D

const screen_size = Vector2(1024, 600)

var MAX_SPEED = 500
var ACCELERATION = 1500
var motion = Vector2.ZERO

func _physics_process(delta):
	var axis = get_input_axis()
	self.rotation = Vector2(0, -1).angle_to(axis)
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
	motion = move_and_slide(motion)
	screenwrap()

func screenwrap():
	global_position.x = fposmod(global_position.x, screen_size.x)
	global_position.y = fposmod(global_position.y, screen_size.y)


func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)
