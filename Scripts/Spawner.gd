extends Node2D

const Boid = preload("res://boid.tscn")

onready var pop_label = get_parent().get_node("UI/pop_label")
onready var t_pop_label = get_parent().get_node("UI/total_pop_label")

const mutation_factor = 5 #ranges from 1 to 18, higher numbers mean more mutation
const mutation_scale_factor = 3 # higher numbers make mutations less meaningful

const max_population = 200
var population = 0
var total_population = 0

func _ready():
	population_change(0)

func toggle_HUD():
	pop_label.visible = !pop_label.visible
	t_pop_label.visible = !t_pop_label.visible

func population_change(amount):
	population += amount
	pop_label.text = "Population: " + str(population)
	if population == max_population:
		pop_label.text += " (max)"
	if amount >= 0:
		total_population += amount
		t_pop_label.text = "Total Population: " + str(total_population)

func spawn_unit(SW, AW, CW, speed, SD, _scale, dmg, MT):
	if population >= max_population:
		return
	
	population_change(1)
	
	var boid = Boid.instance()
	randomize()
	
	# random position
	boid.global_position = Vector2(rand_range(0, 1024), rand_range(0, 600))
	#boid.global_position = Vector2((randi() % 100) * 10, 10) #self.get_global_mouse_position()
	
	# check for mutation
	if randi() % 20 <= mutation_factor:
		SW += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= mutation_factor:
		AW += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= mutation_factor:
		CW += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= mutation_factor:
		if speed < 6 and speed >= 2.5:
			speed += (rand_range(-1, 1))
	if randi() % 20 <= mutation_factor:
		SD += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= mutation_factor:
		_scale += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= mutation_factor:
		dmg += (rand_range(-1, 1) / mutation_scale_factor)
	if randi() % 20 <= 19:#mutation_factor:
		MT += (rand_range(-1, 1) / mutation_scale_factor)
	
	# assign values
	boid.SEPARATION_WEIGHT = SW
	boid.ALIGNMENT_WEIGHT = AW
	boid.COHESION_WEIGHT = CW
	
	boid._speed = speed
	boid._max_speed = speed + 1
	boid._separation_distance = SD
	
	boid.scale = Vector2(_scale, _scale)
	boid.max_hp = _scale * 2
	
	boid.damage = dmg
	
	boid.maturity_time = MT
	boid.get_node("Timer").wait_time = MT
	
	boid.modulate = Color(SW, AW, CW)
	
	var direction = Vector2(round(randf()), round(randf()))
	if direction == Vector2():
		direction = Vector2(0, 1)
	boid.set_direction(direction)
	
	get_parent().add_child(boid)
