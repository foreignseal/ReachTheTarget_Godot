extends Node2D

@export var target_scene: PackedScene = preload("res://scenes/components/Target.tscn")

@export var initial_target_count: int = 1
@export_range(0.0, 1.0) var moving_target_ratio: float = 0.25
@export var label: Label
@export var respawn_on_reach: bool = true

# Spawn Variables
var spawn_locations: Array[Node2D] = []
var occupied_spawns: Array[Node2D] = []


func _ready() -> void:
	for child in get_children():
		if child is Node2D:
			spawn_locations.append(child)
	
	var count: int = clampi(initial_target_count, 0, spawn_locations.size())
	for i in range(count):
		spawn_target()

func spawn_target() -> Area2D:
	if target_scene == null:
		return null
	
	var available_locations: Array[Node2D] = []
	for loc in spawn_locations:
		if not occupied_spawns.has(loc):
			available_locations.append(loc)
	
	var chosen_loc: Node2D = available_locations.pick_random()
	occupied_spawns.append(chosen_loc)
	
	var target_instance: Area2D = target_scene.instantiate()
	target_instance.global_position = chosen_loc.global_position
	
	if randf() < moving_target_ratio:
		target_instance.is_moving_target = true
	
	target_instance.label = label
	
	target_instance.target_reached.connect(func() -> void:
		_on_target_reached.call_deferred(chosen_loc)
	)
	
	add_child(target_instance)
	return target_instance

func _on_target_reached(spawn_location: Node2D) -> void:
	occupied_spawns.erase(spawn_location)
	if respawn_on_reach:
		call_deferred("spawn_target")
