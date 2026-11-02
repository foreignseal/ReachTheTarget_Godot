extends CharacterBody2D

@export var speed: float = 250.0


func _physics_process(delta: float) -> void:
	
	var direction := Vector2(
		(Input.get_axis("move_left", "move_right")), 
		(Input.get_axis("move_up", "move_down"))
	)
	
	velocity = direction * speed;
	move_and_slide()
