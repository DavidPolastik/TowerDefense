extends Node2D
## BuildManager – "stavební systém".
## Umožní stavět dva typy věží (základní / silná) na volná místa mimo cestu.
## Živý náhled ukazuje, kam lze stavět (zelená = ano, červená = ne).

@export var tower_basic_scene: PackedScene
@export var tower_heavy_scene: PackedScene
@export var basic_cost: int = 50
@export var heavy_cost: int = 90
@export var basic_range: float = 160.0
@export var heavy_range: float = 210.0
@export var grid_size: int = 64
@export var min_distance_from_path: float = 48.0

# Vybraný typ věže: -1 = nic (stavba vypnutá), 0 = základní, 1 = silná.
var _selected_type: int = -1

var _path: Path2D
var _towers_container: Node2D
var _preview_pos: Vector2 = Vector2.ZERO
var _preview_valid: bool = false

## Předá cestu a kontejner pro věže (volá Main).
func setup(path: Path2D, towers_container: Node2D) -> void:
	_path = path
	_towers_container = towers_container

## Nastaví vybraný typ věže (napojeno na tlačítka v HUD). -1 = stavba vypnutá.
func set_build_selection(type: int) -> void:
	_selected_type = type
	queue_redraw()

func _build_enabled() -> bool:
	return _selected_type >= 0

func _current_scene() -> PackedScene:
	return tower_heavy_scene if _selected_type == 1 else tower_basic_scene

func _current_cost() -> int:
	return heavy_cost if _selected_type == 1 else basic_cost

func _current_range() -> float:
	return heavy_range if _selected_type == 1 else basic_range

func _process(_delta: float) -> void:
	if not _build_enabled():
		return
	_preview_pos = _snap_to_grid(get_global_mouse_position())
	_preview_valid = _is_valid_position(_preview_pos) and GameManager.gold >= _current_cost()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not _build_enabled() or GameManager.is_game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_build(get_global_mouse_position())

func _try_build(world_pos: Vector2) -> void:
	var target_pos := _snap_to_grid(world_pos)
	if not _is_valid_position(target_pos):
		return
	if not GameManager.spend_gold(_current_cost()):
		return
	var tower := _current_scene().instantiate()
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
	if not _build_enabled():
		return
	var col := Color(0.3, 0.9, 0.4, 0.9) if _preview_valid else Color(0.9, 0.3, 0.3, 0.9)
	var r := _current_range()
	draw_circle(_preview_pos, r, Color(col.r, col.g, col.b, 0.08))
	draw_arc(_preview_pos, r, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.35), 1.5)
	draw_circle(_preview_pos, grid_size * 0.4, Color(col.r, col.g, col.b, 0.35))
	draw_arc(_preview_pos, grid_size * 0.4, 0.0, TAU, 24, col, 2.5)
