extends Control

# Resources
@export var game_scene: PackedScene


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
