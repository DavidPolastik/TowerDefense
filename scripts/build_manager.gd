extends Node2D
# stavba vezi - dva typy, nahled a zvyrazneni volnych poli

@export var tower_basic_scene: PackedScene
@export var tower_heavy_scene: PackedScene
@export var basic_cost: int = 50
@export var heavy_cost: int = 90
@export var basic_range: float = 160.0
@export var heavy_range: float = 210.0
@export var grid_size: int = 64
@export var min_distance_from_path: float = 46.0

const BAR_H := 96.0   # spodni lista

var _selected_type: int = -1   # -1 nic, 0 zakladni, 1 silna
var _path: Path2D
var _towers_container: Node2D
var _preview_pos: Vector2 = Vector2.ZERO
var _preview_valid: bool = false
var _valid_cells: Array[Vector2] = []

func setup(path: Path2D, towers_container: Node2D) -> void:
	_path = path
	_towers_container = towers_container

func set_build_selection(type: int) -> void:
	_selected_type = type
	if _build_enabled():
		_recompute_cells()
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
	_recompute_cells()

func _snap_to_grid(pos: Vector2) -> Vector2:
	var gx := roundf(pos.x / grid_size) * grid_size
	var gy := roundf(pos.y / grid_size) * grid_size
	return Vector2(gx, gy)

# misto musi byt v plose, dost daleko od cesty a bez jine veze
func _is_valid_position(pos: Vector2) -> bool:
	var vp := get_viewport_rect().size
	var m := grid_size * 0.5
	if pos.x < m or pos.x > vp.x - m:
		return false
	if pos.y < m or pos.y > vp.y - BAR_H - m:
		return false
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

func _recompute_cells() -> void:
	_valid_cells.clear()
	var vp := get_viewport_rect().size
	var x := 0.0
	while x <= vp.x:
		var y := 0.0
		while y <= vp.y:
			var pos := Vector2(x, y)
			if _is_valid_position(pos):
				_valid_cells.append(pos)
			y += grid_size
		x += grid_size

func _draw() -> void:
	if not _build_enabled():
		return
	# volna pole
	var s := grid_size * 0.82
	var half := Vector2(s, s) * 0.5
	for c in _valid_cells:
		draw_rect(Rect2(c - half, Vector2(s, s)), Color(0.3, 0.9, 0.45, 0.12))
		draw_rect(Rect2(c - half, Vector2(s, s)), Color(0.3, 0.9, 0.45, 0.35), false, 1.0)
	# nahled u kurzoru + dosah
	var col := Color(0.3, 0.95, 0.45, 1.0) if _preview_valid else Color(0.95, 0.35, 0.3, 1.0)
	var r := _current_range()
	draw_circle(_preview_pos, r, Color(col.r, col.g, col.b, 0.10))
	draw_arc(_preview_pos, r, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.4), 2.0)
	draw_rect(Rect2(_preview_pos - half, Vector2(s, s)), Color(col.r, col.g, col.b, 0.45))
	draw_arc(_preview_pos, grid_size * 0.4, 0.0, TAU, 24, col, 3.0)
