extends Node
## WaveManager – "systém vln".
## Spawnuje nepřátele po vlnách. Každá vlna má víc a silnějších nepřátel.
## Po vyčištění vlny chvíli počká a spustí další. Po poslední vlně = výhra.

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

@export var enemy_scene: PackedScene
@export var time_between_waves: float = 4.0   # pauza mezi vlnami (s)
@export var spawn_interval: float = 0.8       # rozestup spawnování v jedné vlně (s)

# Definice vln – počet nepřátel, jejich HP, rychlost a odměna.
var _waves := [
	{"count": 6,  "health": 24,  "speed": 110.0, "reward": 8},
	{"count": 9,  "health": 32,  "speed": 120.0, "reward": 9},
	{"count": 12, "health": 42,  "speed": 130.0, "reward": 10},
	{"count": 14, "health": 58,  "speed": 135.0, "reward": 12},
	{"count": 18, "health": 80,  "speed": 145.0, "reward": 14},
]

var _path: Path2D
var _current_wave: int = 0

## Předá cestu, po které se budou nepřátelé pohybovat.
func setup(path: Path2D) -> void:
	_path = path

## Spustí spouštění vln (volá se po stisku tlačítka Start).
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
	# Nastavíme parametry ještě před přidáním do stromu (než se spustí _ready).
	enemy.max_health = wave["health"]
	enemy.speed = wave["speed"]
	enemy.reward = wave["reward"]
	_path.add_child(enemy)

## Čeká, dokud jsou na scéně živí nepřátelé.
func _wait_until_cleared() -> void:
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		if GameManager.is_game_over:
			return
		await get_tree().create_timer(0.5).timeout
