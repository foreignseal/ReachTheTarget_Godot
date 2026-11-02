class_name HighscoreManager
extends RefCounted

# Variables
const SAVE_PATH: String = "user://highscores.json"
const MAX_SCORES: int = 3


static func load_scores() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return []
	
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		return []
	
	var data = json.get_data()
	if data is Array:
		return data
	return []

static func save_score(score: int, highest_time: float) -> bool:
	if score <= 0:
		return false
	
	var scores := load_scores()
	var new_entry: Dictionary = {
		"score": score,
		"highest_time": highest_time,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	scores.append(new_entry)
	
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var score_a: int = int(a.get("score", 0))
		var score_b: int = int(b.get("score", 0))
		if score_a != score_b:
			return score_a > score_b
		return float(a.get("highest_time", 0.0)) > float(b.get("highest_time", 0.0))
	)
	
	var is_top_score: bool = (scores.find(new_entry) < MAX_SCORES)
	
	if scores.size() > MAX_SCORES:
		scores.resize(MAX_SCORES)
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores, "\t"))
		file.close()
	
	return is_top_score

static func clear_scores() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


static func format_time(seconds: float) -> String:
	var total_sec: int = max(0, int(ceil(seconds)))
	var minutes: int = total_sec / 60
	var rem_sec: int = total_sec % 60
	return "%02d:%02d" % [minutes, rem_sec]
