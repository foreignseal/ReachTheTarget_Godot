extends CharacterBody2D

signal player_moved_first_time

# Player variables
@export var speed: float = 250.0
@export var spawn_point: Node2D
var has_moved: bool = false


func _ready() -> void:
	add_to_group("player")
	if spawn_point:
		global_position = spawn_point.global_position

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		(Input.get_axis("move_left", "move_right")), 
		(Input.get_axis("move_up", "move_down"))
	)
	
	if not has_moved and direction != Vector2.ZERO:
		has_moved = true
		player_moved_first_time.emit()
	
	velocity = direction * speed
	move_and_slide()

func respawn() -> void:
	if spawn_point:
		global_position = spawn_point.global_position
	velocity = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
