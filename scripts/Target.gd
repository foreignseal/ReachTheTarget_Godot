extends Area2D

signal target_reached

# Resources
@export var label: Label # Label to change message
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: CPUParticles2D = get_node_or_null("CPUParticles2D")

# Animation when reached
@export var shrink_speed: float = 3.5
@export var min_scale: float = 0.05

# Target Variables
var is_reached: bool = false


func _ready() -> void:
	add_to_group("targets")


func _process(delta: float) -> void:
	if is_reached:
		scale = scale.move_toward(Vector2.ZERO, shrink_speed * delta)
		if scale.x <= min_scale:
			queue_free()

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
