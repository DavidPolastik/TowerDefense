extends Node
## GameManager – globální herní stav (autoload singleton).
## Drží zlato, životy a skóre a vysílá signály, na které reagují ostatní
## systémy (HUD, wave manager, věže). Toto je "ekonomický systém" a
## "systém životů" z návrhu hry.

# Signály – ostatní uzly se na ně připojí a reagují na změnu stavu.
signal gold_changed(amount: int)
signal lives_changed(amount: int)
signal score_changed(amount: int)
signal game_over(victory: bool)

const STARTING_GOLD := 120
const STARTING_LIVES := 20

# Počáteční hodnoty pro aktuální úroveň (nastaví se přes set_start před reset()).
var start_gold: int = STARTING_GOLD
var start_lives: int = STARTING_LIVES

var gold: int = STARTING_GOLD
var lives: int = STARTING_LIVES
var score: int = 0
var is_game_over: bool = false

## Nastaví počáteční zlato a životy podle úrovně.
func set_start(gold_amount: int, lives_amount: int) -> void:
	start_gold = gold_amount
	start_lives = lives_amount

## Vrátí stav do výchozích hodnot (volá se při startu / restartu hry).
func reset() -> void:
	gold = start_gold
	lives = start_lives
	score = 0
	is_game_over = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)
	score_changed.emit(score)

## Přidá zlato (odměna za zabití nepřítele).
func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

## Pokusí se utratit zlato. Vrací true, pokud na to hráč měl dost.
func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true

## Ubere život – nepřítel se dostal k základně.
func lose_life(amount: int = 1) -> void:
	if is_game_over:
		return
	lives -= amount
	if lives <= 0:
		lives = 0
	lives_changed.emit(lives)
	if lives <= 0:
		_trigger_game_over(false)

## Přičte skóre.
func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

## Vyhraje hru (všechny vlny přežity).
func win() -> void:
	if not is_game_over:
		_trigger_game_over(true)

func _trigger_game_over(victory: bool) -> void:
	is_game_over = true
	game_over.emit(victory)
