extends CharacterBody2D

# Player variables
@export var speed: float = 250.0
@export var spawn_point: Node2D


func _ready() -> void:
	add_to_group("player")
	if spawn_point:
		global_position = spawn_point.global_position

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		(Input.get_axis("move_left", "move_right")), 
		(Input.get_axis("move_up", "move_down"))
	)
	
	velocity = direction * speed
	move_and_slide()

func respawn() -> void:
	if spawn_point:
		global_position = spawn_point.global_position
	velocity = Vector2.ZERO
