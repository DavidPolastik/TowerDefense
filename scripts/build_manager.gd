extends Node2D
## BuildManager – "stavební systém".
## Ve stavebním režimu umožní hráči kliknutím postavit věž na volné místo
## (mimo cestu a mimo jinou věž), pokud má dost zlata.

@export var tower_scene: PackedScene
@export var tower_cost: int = 50
@export var grid_size: int = 64
@export var min_distance_from_path: float = 48.0

var _path: Path2D
var _towers_container: Node2D
var _build_enabled: bool = false

## Předá cestu a kontejner pro věže (volá Main).
func setup(path: Path2D, towers_container: Node2D) -> void:
	_path = path
	_towers_container = towers_container

## Zapne/vypne stavební režim (napojeno na přepínací tlačítko v HUD).
func set_build_mode(enabled: bool) -> void:
	_build_enabled = enabled

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
