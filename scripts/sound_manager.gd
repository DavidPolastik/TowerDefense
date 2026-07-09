extends Node
# prehravani zvuku pres pool prehravacu, at se muzou prekryvat (autoload)

const SHOT: AudioStream = preload("res://assets/audio/shot.ogg")
const SHOT_HEAVY: AudioStream = preload("res://assets/audio/shot_heavy.ogg")
const EXPLOSION: AudioStream = preload("res://assets/audio/explosion.ogg")

const POOL_SIZE := 12

var _players: Array[AudioStreamPlayer] = []
var _next: int = 0

func _ready() -> void:
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func _play(stream: AudioStream, volume_db: float) -> void:
	var p := _players[_next]
	_next = (_next + 1) % POOL_SIZE
	p.stream = stream
	p.volume_db = volume_db
	p.play()

func play_shot() -> void:
	_play(SHOT, -14.0)

func play_shot_heavy() -> void:
	_play(SHOT_HEAVY, -11.0)

func play_explosion() -> void:
	_play(EXPLOSION, -9.0)
