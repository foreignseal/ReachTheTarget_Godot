extends Control

const HighscoreManager = preload("res://scripts/HighscoreManager.gd")

# Resources
@export var game_scene: PackedScene

# UI References
@onready var highscores_modal: Control = $HighscoresModal
@onready var score_list_container: VBoxContainer = $HighscoresModal/CenterContainer/Card/VBox/ScoresContainer


func _ready() -> void:
	highscores_modal.visible = false

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_highscores_button_pressed() -> void:
	_update_highscores_display()
	highscores_modal.visible = true

func _on_close_highscores_pressed() -> void:
	highscores_modal.visible = false

func _on_reset_highscores_pressed() -> void:
	HighscoreManager.clear_scores()
	_update_highscores_display()

func _update_highscores_display() -> void:
	if not score_list_container:
		return
	
	for child in score_list_container.get_children():
		score_list_container.remove_child(child)
		child.queue_free()
	
	var scores := HighscoreManager.load_scores()
	if scores.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No highscores yet!\nPlay a game to set a record."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_override("font", preload("res://assets/fonts/lilita_one_regular.ttf"))
		empty_lbl.add_theme_font_size_override("font_size", 22)
		empty_lbl.add_theme_color_override("font_color", Color(0.45, 0.47, 0.5, 1.0))
		score_list_container.add_child(empty_lbl)
		return
	
	var ranks := ["#1", "#2", "#3"]
	var rank_colors := [
		Color(0.85, 0.65, 0.1, 1.0), # Gold
		Color(0.55, 0.6, 0.65, 1.0), # Silver
		Color(0.7, 0.45, 0.25, 1.0)  # Bronze
	]
	
	for i in range(scores.size()):
		var entry: Dictionary = scores[i]
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 16)
		
		var rank_lbl := Label.new()
		rank_lbl.text = ranks[i] if i < ranks.size() else "#%d" % (i + 1)
		rank_lbl.custom_minimum_size = Vector2(40, 0)
		rank_lbl.add_theme_font_override("font", preload("res://assets/fonts/lilita_one_regular.ttf"))
		rank_lbl.add_theme_font_size_override("font_size", 26)
		rank_lbl.add_theme_color_override("font_color", rank_colors[i] if i < rank_colors.size() else Color.DARK_GRAY)
		row.add_child(rank_lbl)
		
		var score_lbl := Label.new()
		var target_count: int = int(entry.get("score", 0))
		var peak_time: String = HighscoreManager.format_time(float(entry.get("highest_time", 60.0)))
		score_lbl.text = "%d TARGETS   (Peak: %s)" % [target_count, peak_time]
		score_lbl.add_theme_font_override("font", preload("res://assets/fonts/lilita_one_regular.ttf"))
		score_lbl.add_theme_font_size_override("font_size", 24)
		score_lbl.add_theme_color_override("font_color", Color(0.12, 0.12, 0.14, 1.0))
		row.add_child(score_lbl)
		
		score_list_container.add_child(row)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if highscores_modal and highscores_modal.visible:
			highscores_modal.visible = false
		else:
			get_tree().quit()
