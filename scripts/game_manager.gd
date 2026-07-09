extends Node
# globalni stav hry - zlato, zivoty, skore (autoload)

signal gold_changed(amount: int)
signal lives_changed(amount: int)
signal score_changed(amount: int)
signal game_over(victory: bool)

const STARTING_GOLD := 120
const STARTING_LIVES := 20

var start_gold: int = STARTING_GOLD
var start_lives: int = STARTING_LIVES

var gold: int = STARTING_GOLD
var lives: int = STARTING_LIVES
var score: int = 0
var is_game_over: bool = false

func set_start(gold_amount: int, lives_amount: int) -> void:
	start_gold = gold_amount
	start_lives = lives_amount

func reset() -> void:
	gold = start_gold
	lives = start_lives
	score = 0
	is_game_over = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)
	score_changed.emit(score)

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true

func lose_life(amount: int = 1) -> void:
	if is_game_over:
		return
	lives -= amount
	if lives <= 0:
		lives = 0
	lives_changed.emit(lives)
	if lives <= 0:
		_trigger_game_over(false)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func win() -> void:
	if not is_game_over:
		_trigger_game_over(true)

func _trigger_game_over(victory: bool) -> void:
	is_game_over = true
	game_over.emit(victory)
