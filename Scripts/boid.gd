extends KinematicBody2D

const screen_size = Vector2(1024, 600)

const mutation_factor = 1 #ranges from 1 to 18, higher numbers mean more mutation
const mutation_scale_factor = 5 # higher numbers make mutations less meaningful

# MUTABLE BOID STATS
var SEPARATION_WEIGHT = 0.5
var ALIGNMENT_WEIGHT = 0.5
var COHESION_WEIGHT = 0.1
var _speed = 3
var _separation_distance = 20
var _scale = 6
var damage = 2
var maturity_time = 8

onready var unit_spawner = get_parent().get_node("Spawner")

var _max_speed = 3

var _direction = Vector2(0, 1)
var _local_flockmates = []

var max_hp = 20 # tied to scale
var hp = 20


func _physics_process(_delta):
	self.rotation = Vector2(0, 1).angle_to(_direction)
	screenwrap()
	var collision = self.move_and_collide(_direction * _speed)
	if collision:
		take_damage(damage)
		if collision.collider is StaticBody2D or (collision.collider.is_in_group("player")):
			_direction = _collision_reaction_direction(collision)
	else:
		_direction = _flock_direction()


func screenwrap():
	global_position.x = fposmod(global_position.x, screen_size.x)
	global_position.y = fposmod(global_position.y, screen_size.y)

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		unit_spawner.population_change(-1)
		queue_free()

func heal_damage(amount):
	hp += amount
	if hp > max_hp:
		hp = max_hp

# Inverts the direction when hitting a collider.
# This implementation handles colliding with Tilemaps specifically.
func _collision_reaction_direction(collision):
	return (collision.position - collision.normal).direction_to(self.position)


# This function is pretty much all you need for calculating
# the flocking movement
func _flock_direction():
	var separation = Vector2()
	var heading = _direction
	var cohesion = Vector2()

	for flockmate in _local_flockmates:
		heading += flockmate.get_direction()
		cohesion += flockmate.position

		var distance = self.position.distance_to(flockmate.position)

		if distance < _separation_distance:
			if distance != 0 and _speed != 0:
				separation -= (flockmate.position - self.position).normalized() * (_separation_distance / distance * _speed)

	if _local_flockmates.size() > 0:
		heading /= _local_flockmates.size()
		cohesion /= _local_flockmates.size()
		var center_direction = self.position.direction_to(cohesion)
		var center_speed = _max_speed * self.position.distance_to(cohesion) / $detect_radius/CollisionShape2D.shape.radius
		cohesion = center_direction * center_speed

	return (
		_direction +
		separation * SEPARATION_WEIGHT +
		heading * ALIGNMENT_WEIGHT +
		cohesion * COHESION_WEIGHT
	).clamped(_max_speed)


func get_direction():
	return _direction


func set_direction(direction):
	_direction = direction

func _on_detect_radius_body_entered(body):
	if body == self:
		return

	if body.is_in_group("boid"):
		_local_flockmates.push_back(body)


func _on_detect_radius_body_exited(body):
	if body.is_in_group("boid"):
		_local_flockmates.erase(body)


func _on_Timer_timeout():
	unit_spawner.spawn_unit(SEPARATION_WEIGHT, ALIGNMENT_WEIGHT, COHESION_WEIGHT, _speed, _separation_distance, _scale, damage, maturity_time)
	#spawn_unit(SEPARATION_WEIGHT, ALIGNMENT_WEIGHT, COHESION_WEIGHT, _speed, _separation_distance)
