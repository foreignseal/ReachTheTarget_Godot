extends Area2D

signal target_reached

# Resources
@export var label: Label 
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = get_node_or_null("CPUParticles2D")

# Animation when reached
@export var shrink_speed: float = 3.5
@export var min_scale: float = 0.05

# AI / Movement Behavior
@export var is_moving_target: bool = false
@export var move_speed: float = 120.0 
@export var moving_color: Color = Color(0.35, 0.85, 1.0, 1.0) 

@export var wander_boundary: float = 1600.0

# Target Variables
var is_reached: bool = false
var move_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0


func _ready() -> void:
	add_to_group("targets")
	
	if is_moving_target:
		if sprite:
			sprite.modulate = moving_color
		move_direction = _find_clear_direction()
		wander_timer = randf_range(2.0, 4.0)

func _process(delta: float) -> void:
	if is_reached:
		scale = scale.move_toward(Vector2.ZERO, shrink_speed * delta)
		if scale.x <= min_scale:
			queue_free()

func _physics_process(delta: float) -> void:
	if not is_moving_target or is_reached:
		return
	
	wander_timer -= delta
	
	if global_position.length() > wander_boundary:
		move_direction = (-global_position).normalized()
		wander_timer = randf_range(2.0, 3.5)
	elif _is_ray_blocked(global_position, move_direction, 90.0):
		move_direction = _find_clear_direction()
		wander_timer = randf_range(2.0, 3.5)
	elif wander_timer <= 0.0:
		move_direction = _find_clear_direction()
		wander_timer = randf_range(2.0, 4.0)
	
	var moved: bool = move_with_collision(move_direction * move_speed * delta)
	if not moved:
		move_direction = _find_clear_direction()

func _find_clear_direction() -> Vector2:
	var candidates: Array[Vector2] = []
	for i in range(8):
		var angle: float = i * (TAU / 8.0) + randf_range(-0.15, 0.15)
		var dir := Vector2.RIGHT.rotated(angle)
		if not _is_ray_blocked(global_position, dir, 100.0):
			candidates.append(dir)
	
	if not candidates.is_empty():
		return candidates.pick_random()
	
	if global_position != Vector2.ZERO:
		return (-global_position).normalized()
	return Vector2.RIGHT.rotated(randf() * TAU)

func _is_ray_blocked(from_pos: Vector2, dir: Vector2, distance: float) -> bool:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from_pos, from_pos + dir * distance)
	query.collision_mask = 1 # Environment / StaticBody2D walls
	query.exclude = [get_rid()]
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return false
	if result.collider is StaticBody2D:
		return true
	return false

func move_with_collision(motion: Vector2) -> bool:
	if motion == Vector2.ZERO:
		return false
	
	if not _collides_at(global_position + motion):
		global_position += motion
		return true
	
	var motion_x := Vector2(motion.x, 0.0)
	if motion.x != 0.0 and not _collides_at(global_position + motion_x):
		global_position += motion_x
		return true
	
	var motion_y := Vector2(0.0, motion.y)
	if motion.y != 0.0 and not _collides_at(global_position + motion_y):
		global_position += motion_y
		return true
	
	return false

func _collides_at(target_pos: Vector2) -> bool:
	if not collision_shape or not collision_shape.shape:
		return false
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(0.0, target_pos)
	query.collision_mask = 1
	query.exclude = [get_rid()]
	
	var results := space_state.intersect_shape(query, 5)
	for hit in results:
		if hit.collider is StaticBody2D:
			return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if is_reached:
		return
	
	if body.name == "Player":
		is_reached = true
		collision_shape.set_deferred("disabled", true)
		target_reached.emit()
		
		if label:
			label.text = "TARGET REACHED!"
		
		spawn_particles()

func spawn_particles() -> void:
	var particle_node: CPUParticles2D = particles
	
	if particle_node:
		if sprite:
			particle_node.color = sprite.modulate
		if get_parent():
			particle_node.reparent(get_parent())
	
	particle_node.emitting = true
	particle_node.finished.connect(particle_node.queue_free)
