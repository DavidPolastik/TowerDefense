extends Node
# spousti vlny nepratel, kazda dalsi je silnejsi

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

@export var enemy_scene: PackedScene
@export var time_between_waves: float = 4.0
@export var spawn_interval: float = 0.8

var _waves: Array = []
var _path: Path2D
var _current_wave: int = 0

func setup(path: Path2D, waves: Array) -> void:
	_path = path
	_waves = waves

func wave_total() -> int:
	return _waves.size()

func start() -> void:
	_run_waves()

func _run_waves() -> void:
	while _current_wave < _waves.size():
		if GameManager.is_game_over:
			return
		var wave_index := _current_wave
		_current_wave += 1
		wave_started.emit(_current_wave)
		await _spawn_wave(_waves[wave_index])
		await _wait_until_cleared()
		if GameManager.is_game_over:
			return
		wave_completed.emit(_current_wave)
		await get_tree().create_timer(time_between_waves).timeout
	all_waves_completed.emit()
	GameManager.win()

func _spawn_wave(wave: Dictionary) -> void:
	for i in wave["count"]:
		if GameManager.is_game_over:
			return
		_spawn_enemy(wave)
		await get_tree().create_timer(spawn_interval).timeout

func _spawn_enemy(wave: Dictionary) -> void:
	if enemy_scene == null or _path == null:
		return
	var enemy := enemy_scene.instantiate()
	# nastavit parametry pred pridanim do stromu
	enemy.max_health = wave["health"]
	enemy.speed = wave["speed"]
	enemy.reward = wave["reward"]
	_path.add_child(enemy)

func _wait_until_cleared() -> void:
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		if GameManager.is_game_over:
			return
		await get_tree().create_timer(0.5).timeout
