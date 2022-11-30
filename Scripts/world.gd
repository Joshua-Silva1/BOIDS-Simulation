extends Node2D

const Boid = preload("res://boid.tscn")

onready var time = 0

# add a boid on mouse click
func _unhandled_input(event):
	if event is InputEventMouseButton and  event.button_index == BUTTON_LEFT and event.pressed:
		_create_boid()
		$Spawner.population_change(1)
	if event.is_action_pressed("toggle_HUD"):
		$Spawner.toggle_HUD()

func _create_boid():
	var boid = Boid.instance()
	add_child(boid)
	boid.global_position = self.get_global_mouse_position()
	randomize()
	var direction = Vector2(round(randf()), round(randf()))
	if direction == Vector2():
		direction = Vector2(0, 1)
	boid.set_direction(direction)

func _on_Timer_timeout():
	pass # Replace with function body.
