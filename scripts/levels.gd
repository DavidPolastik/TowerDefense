extends Node
# data urovni + postup a nastaveni, uklada se do user://save.cfg (autoload)

const SAVE_PATH := "user://save.cfg"

var current: int = 0        # index hrane urovne
var unlocked: int = 1       # kolik urovni je odemceno

var volume: float = 0.8
var fullscreen: bool = false
var game_speed: float = 1.0

# kazda uroven: nazev, zlato/zivoty, pozadi, body cesty, vlny
var levels: Array = [
	{
		"name": "1 – Louka",
		"start_gold": 160,
		"start_lives": 20,
		"bg": "res://assets/bg_grass.png",
		"path": PackedVector2Array([
			Vector2(-40, 130), Vector2(1300, 130), Vector2(1300, 335),
			Vector2(140, 335), Vector2(140, 540), Vector2(1200, 540),
		]),
		"waves": [
			{"count": 6, "health": 22, "speed": 110.0, "reward": 9},
			{"count": 8, "health": 30, "speed": 115.0, "reward": 9},
			{"count": 10, "health": 44, "speed": 125.0, "reward": 10},
			{"count": 12, "health": 62, "speed": 130.0, "reward": 12},
		],
	},
	{
		"name": "2 – Poušť",
		"start_gold": 150,
		"start_lives": 18,
		"bg": "res://assets/bg_sand.png",
		"path": PackedVector2Array([
			Vector2(-40, 110), Vector2(1300, 110), Vector2(1300, 290),
			Vector2(140, 290), Vector2(140, 470), Vector2(1300, 470),
			Vector2(1300, 650), Vector2(140, 650),
		]),
		"waves": [
			{"count": 8, "health": 30, "speed": 115.0, "reward": 8},
			{"count": 11, "health": 44, "speed": 125.0, "reward": 9},
			{"count": 13, "health": 60, "speed": 130.0, "reward": 10},
			{"count": 15, "health": 84, "speed": 138.0, "reward": 12},
			{"count": 18, "health": 110, "speed": 145.0, "reward": 14},
		],
	},
	{
		"name": "3 – Pevnost",
		"start_gold": 140,
		"start_lives": 15,
		"bg": "res://assets/bg_stone.png",
		"path": PackedVector2Array([
			Vector2(-40, 120), Vector2(1330, 120), Vector2(1330, 325),
			Vector2(120, 325), Vector2(120, 530), Vector2(1210, 530),
		]),
		"waves": [
			{"count": 10, "health": 40, "speed": 120.0, "reward": 8},
			{"count": 13, "health": 60, "speed": 130.0, "reward": 9},
			{"count": 16, "health": 90, "speed": 138.0, "reward": 10},
			{"count": 18, "health": 130, "speed": 145.0, "reward": 12},
			{"count": 20, "health": 175, "speed": 150.0, "reward": 13},
			{"count": 24, "health": 230, "speed": 158.0, "reward": 15},
		],
	},
]

func _ready() -> void:
	_load()
	_apply_settings()

func level_count() -> int:
	return levels.size()

func get_level(i: int) -> Dictionary:
	return levels[i]

func current_level() -> Dictionary:
	return levels[current]

func is_unlocked(i: int) -> bool:
	return i < unlocked

func has_next() -> bool:
	return current + 1 < level_count()

func complete_current() -> void:
	# po vyhre odemkni dalsi uroven
	unlocked = max(unlocked, min(level_count(), current + 2))
	_save()

func set_volume(v: float) -> void:
	volume = clampf(v, 0.0, 1.0)
	_apply_settings()
	_save()

func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply_settings()
	_save()

func set_game_speed(v: float) -> void:
	game_speed = v
	_save()

func _apply_settings() -> void:
	var db: float = -60.0 if volume <= 0.001 else linear_to_db(volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked", unlocked)
	cfg.set_value("settings", "volume", volume)
	cfg.set_value("settings", "fullscreen", fullscreen)
	cfg.set_value("settings", "game_speed", game_speed)
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	unlocked = int(cfg.get_value("progress", "unlocked", 1))
	volume = float(cfg.get_value("settings", "volume", 0.8))
	fullscreen = bool(cfg.get_value("settings", "fullscreen", false))
	game_speed = float(cfg.get_value("settings", "game_speed", 1.0))
