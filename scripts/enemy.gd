extends PathFollow2D
## Enemy – nepřítel, který se pohybuje po cestě (Path2D).
## Má životy (HP), při zásahu je ztrácí, po smrti dá hráči zlato.
## Když dojde na konec cesty, ubere hráči život.
## Nepřítel se hlásí do skupiny "enemies", aby ho věže našly (bez fyziky).

signal died(reward: int)
signal reached_end()

@export var speed: float = 120.0       # rychlost pohybu po cestě (px/s)
@export var max_health: int = 30
@export var reward: int = 10           # zlato za zabití
@export var life_cost: int = 1         # kolik životů ubere na konci

var health: int
var _dead: bool = false
var _prev_pos: Vector2
@onready var body: Node2D = $Body
@onready var turret: Sprite2D = $Body/Turret

func _ready() -> void:
	health = max_health
	rotates = false
	loop = false
	add_to_group("enemies")
	_prev_pos = global_position
	queue_redraw()

func _physics_process(delta: float) -> void:
	if _dead:
		return
	progress += speed * delta
	# Natočení tanku ve směru jízdy (sprite míří nahoru, proto +PI/2).
	# Otáčíme jen "Body" (korbu+věž), takže HP bar zůstává vodorovný.
	var move := global_position - _prev_pos
	if move.length() > 0.01:
		body.rotation = move.angle() + PI / 2.0
	_prev_pos = global_position
	# Věžička tanku míří na nejbližší věž hráče (nezávisle na směru jízdy).
	var tower := _find_nearest_tower()
	if tower != null:
		turret.global_rotation = (tower.global_position - global_position).angle() + PI / 2.0
	else:
		turret.rotation = 0.0
	# progress_ratio dosáhne 1.0 na konci cesty.
	if progress_ratio >= 1.0:
		_reach_end()

## Najde nejbližší věž hráče (skupina "towers").
func _find_nearest_tower() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for t in get_tree().get_nodes_in_group("towers"):
		if not is_instance_valid(t):
			continue
		var tower := t as Node2D
		var d := global_position.distance_to(tower.global_position)
		if d < best_dist:
			best_dist = d
			best = tower
	return best

## Zásah projektilem – ubere HP, případně nepřítele zabije.
func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	queue_redraw()
	if health <= 0:
		_die()

func _die() -> void:
	_dead = true
	remove_from_group("enemies")
	Sfx.play_explosion()
	GameManager.add_gold(reward)
	GameManager.add_score(reward)
	died.emit(reward)
	queue_free()

func _reach_end() -> void:
	_dead = true
	remove_from_group("enemies")
	GameManager.lose_life(life_cost)
	reached_end.emit()
	queue_free()

func _draw() -> void:
	# Jednoduchý HP bar nad nepřítelem.
	if _dead:
		return
	var bar_w := 40.0
	var bar_h := 6.0
	var ratio: float = clampf(float(health) / float(max_health), 0.0, 1.0)
	var top_left := Vector2(-bar_w / 2.0, -26.0)
	draw_rect(Rect2(top_left, Vector2(bar_w, bar_h)), Color(0.12, 0.12, 0.12))
	draw_rect(Rect2(top_left, Vector2(bar_w * ratio, bar_h)), Color(0.25, 0.9, 0.35))
