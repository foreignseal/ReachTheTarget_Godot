extends Node2D


# Game Settings
@export var time_limit: float = 60.0 # 1 minute
@export var time_add_target: float = 5.0 # +5 seconds per target
@export var time_penalty_danger: float = 15.0 # -15 seconds per danger zone

# Game States
enum GameState { WAITING_FOR_START, PLAYING, GAME_OVER }
var current_state: GameState = GameState.WAITING_FOR_START
var time_left: float = 60.0
var highest_time: float = 60.0
var score: int = 0

# Scene References
@onready var player: CharacterBody2D = $Player
@onready var target_spawns: Node2D = $TargetSpawns

# UI References
@onready var timer_label: Label = $UI/HUD/TimerContainer/TimerLabel
@onready var time_change_label: Label = $UI/HUD/TimerContainer/TimeChangeLabel
@onready var score_label: Label = $UI/HUD/ScoreLabel

# Screen
@onready var game_over_screen: Control = $UI/GameOverScreen
@onready var game_over_stats_label: Label = $UI/GameOverScreen/CenterContainer/Card/VBox/StatsLabel

var time_change_tween: Tween


func _ready() -> void:
	time_left = time_limit
	highest_time = time_limit
	_update_hud()
	
	game_over_screen.visible = false
	time_change_label.visible = false
	
	player.player_moved_first_time.connect(_on_player_first_move)
	
	target_spawns.target_collected.connect(_on_target_collected)
	
	for child in get_children():
		if child.name.begins_with("DangerZone") and child.has_signal("player_entered"):
			child.player_entered.connect(_on_danger_zone_player_entered)

func _physics_process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			_update_hud()
			trigger_game_over()
		else:
			_update_hud()

func _on_player_first_move() -> void:
	if current_state == GameState.WAITING_FOR_START:
		current_state = GameState.PLAYING

func _on_target_collected() -> void:
	if current_state != GameState.PLAYING:
		return
	
	score += 1
	modify_time(time_add_target)

func _on_danger_zone_player_entered(_body: Node2D) -> void:
	if current_state != GameState.PLAYING:
		return
	
	modify_time(-time_penalty_danger)

func modify_time(delta_time: float) -> void:
	time_left = max(0.0, time_left + delta_time)
	if time_left > highest_time:
		highest_time = time_left
	
	_update_hud()
	_show_time_change(delta_time)
	
	if time_left <= 0.0 and current_state == GameState.PLAYING:
		trigger_game_over()

func _show_time_change(amount: float) -> void:
	if not time_change_label:
		return
	
	if time_change_tween and time_change_tween.is_valid():
		time_change_tween.kill()
	
	if amount > 0:
		time_change_label.text = "+%ds" % int(amount)
		time_change_label.modulate = Color(0.2, 0.9, 0.35, 1.0)
	else:
		time_change_label.text = "%ds" % int(amount)
		time_change_label.modulate = Color(0.95, 0.2, 0.2, 1.0)
	
	time_change_label.visible = true
	time_change_label.scale = Vector2(1.2, 1.2)
	
	time_change_tween = create_tween()
	time_change_tween.set_parallel(true)
	time_change_tween.tween_property(time_change_label, "scale", Vector2.ONE, 0.2)
	time_change_tween.tween_property(time_change_label, "modulate:a", 0.0, 1.2).set_delay(0.4)
	time_change_tween.chain().tween_callback(func(): time_change_label.visible = false)

func _update_hud() -> void:
	timer_label.text = _format_time(time_left)
	
	if time_left < 20.0 and current_state == GameState.PLAYING:
		timer_label.modulate = Color(0.95, 0.2, 0.2, 1.0)
	else:
		timer_label.modulate = Color(0.12, 0.12, 0.14, 1.0)
		
	score_label.text = "TARGETS: %d" % score

func _format_time(seconds: float) -> String:
	var total_sec: int = max(0, int(ceil(seconds)))
	var minutes: int = total_sec / 60
	var rem_sec: int = total_sec % 60
	return "%02d:%02d" % [minutes, rem_sec]

func trigger_game_over() -> void:
	if current_state == GameState.GAME_OVER:
		return
	
	current_state = GameState.GAME_OVER
	player.set_physics_process(false)
	game_over_stats_label.text = "Targets Collected: %d\nHighest Time: %s" % [score, _format_time(highest_time)]
	game_over_screen.visible = true

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
