extends Node2D
## BuildManager – "stavební systém".
## Ve stavebním režimu umožní hráči kliknutím postavit věž na volné místo
## (mimo cestu a mimo jinou věž), pokud má dost zlata.

@export var tower_scene: PackedScene
@export var tower_cost: int = 50
@export var grid_size: int = 64
@export var min_distance_from_path: float = 48.0

const PREVIEW_RANGE := 160.0   # dosah zobrazený v náhledu

var _path: Path2D
var _towers_container: Node2D
var _build_enabled: bool = false
var _preview_pos: Vector2 = Vector2.ZERO
var _preview_valid: bool = false

## Předá cestu a kontejner pro věže (volá Main).
func setup(path: Path2D, towers_container: Node2D) -> void:
	_path = path
	_towers_container = towers_container

## Zapne/vypne stavební režim (napojeno na přepínací tlačítko v HUD).
func set_build_mode(enabled: bool) -> void:
	_build_enabled = enabled
	queue_redraw()

func _process(_delta: float) -> void:
	# Živý náhled: kam se věž postaví a zda je to platné (zelená/červená).
	if not _build_enabled:
		return
	_preview_pos = _snap_to_grid(get_global_mouse_position())
	_preview_valid = _is_valid_position(_preview_pos) and GameManager.gold >= tower_cost
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not _build_enabled or GameManager.is_game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_build(get_global_mouse_position())

func _try_build(world_pos: Vector2) -> void:
	var target_pos := _snap_to_grid(world_pos)
	if not _is_valid_position(target_pos):
		return
	if not GameManager.spend_gold(tower_cost):
		return
	var tower := tower_scene.instantiate()
	tower.global_position = target_pos
	_towers_container.add_child(tower)

func _snap_to_grid(pos: Vector2) -> Vector2:
	var gx := roundf(pos.x / grid_size) * grid_size
	var gy := roundf(pos.y / grid_size) * grid_size
	return Vector2(gx, gy)

## Ověří, že místo je volné: dost daleko od cesty a bez jiné věže.
func _is_valid_position(pos: Vector2) -> bool:
	if _path != null and _path.curve != null:
		var local := _path.to_local(pos)
		var closest_local := _path.curve.get_closest_point(local)
		var closest_global := _path.to_global(closest_local)
		if closest_global.distance_to(pos) < min_distance_from_path:
			return false
	if _towers_container != null:
		for t in _towers_container.get_children():
			if t is Node2D and (t as Node2D).global_position.distance_to(pos) < grid_size * 0.75:
				return false
	return true

func _draw() -> void:
	# Náhled umístění věže (jen ve stavebním režimu).
	if not _build_enabled:
		return
	var col := Color(0.3, 0.9, 0.4, 0.9) if _preview_valid else Color(0.9, 0.3, 0.3, 0.9)
	# Dosah budoucí věže.
	draw_circle(_preview_pos, PREVIEW_RANGE, Color(col.r, col.g, col.b, 0.08))
	draw_arc(_preview_pos, PREVIEW_RANGE, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.35), 1.5)
	# Značka místa (kruh + křížek při neplatném).
	draw_circle(_preview_pos, grid_size * 0.4, Color(col.r, col.g, col.b, 0.35))
	draw_arc(_preview_pos, grid_size * 0.4, 0.0, TAU, 24, col, 2.5)
