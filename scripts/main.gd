extends Node2D
## Main – kořenový uzel hry. Sestaví úroveň podle dat z autoloadu Levels
## (cesta, vlny, počáteční zlato, pozadí) a propojí systémy.

@onready var path: Path2D = $EnemyPath
@onready var towers: Node2D = $Towers
@onready var wave_manager: Node = $WaveManager
@onready var build_manager: Node2D = $BuildManager
@onready var hud: CanvasLayer = $HUD
@onready var base: Sprite2D = $Base
@onready var bg: TextureRect = $Background/Bg

func _ready() -> void:
	Engine.time_scale = Levels.game_speed   # rychlost hry z nastavení
	var lvl: Dictionary = Levels.current_level()

	# Pozadí (dlaždicová textura dle úrovně).
	bg.texture = load(lvl["bg"])

	# Cesta z bodů úrovně.
	var curve := Curve2D.new()
	for p in lvl["path"]:
		curve.add_point(p)
	path.curve = curve

	# Hrad na konci cesty.
	var pts: PackedVector2Array = lvl["path"]
	base.global_position = pts[pts.size() - 1]

	# Ekonomika + reset stavu.
	GameManager.set_start(lvl["start_gold"], lvl["start_lives"])
	GameManager.reset()

	# Systémy.
	wave_manager.setup(path, lvl["waves"])
	build_manager.setup(path, towers)

	# HUD.
	hud.set_level_info(lvl["name"], wave_manager.wave_total())
	hud.build_selection_changed.connect(build_manager.set_build_selection)
	hud.start_pressed.connect(_on_start_pressed)
	wave_manager.wave_started.connect(hud.set_wave)

	# Po vyhrané úrovni odemkni další.
	GameManager.game_over.connect(_on_game_over)

	queue_redraw()

func _on_start_pressed() -> void:
	wave_manager.start()

func _on_game_over(victory: bool) -> void:
	if victory:
		Levels.complete_current()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			# Restart úrovně.
			get_tree().reload_current_scene()
		elif event.keycode == KEY_ESCAPE:
			# Návrat do hlavního menu.
			Engine.time_scale = 1.0
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _draw() -> void:
	# Vykreslí cestu jako širokou čáru, aby hráč viděl, kudy jdou nepřátelé.
	if path != null and path.curve != null:
		var pts := path.curve.get_baked_points()
		if pts.size() > 1:
			# Tmavý obrys, aby byla cesta vidět na jakémkoli pozadí.
			draw_polyline(pts, Color(0.35, 0.27, 0.16, 0.95), 54.0)
			draw_polyline(pts, Color(0.86, 0.75, 0.55, 1.0), 44.0)
