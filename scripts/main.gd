extends Node2D
## Main – kořenový uzel hry, propojuje všechny systémy.
## Vykresluje také cestu (Path2D sám o sobě nic nekreslí).

@onready var path: Path2D = $EnemyPath
@onready var towers: Node2D = $Towers
@onready var wave_manager: Node = $WaveManager
@onready var build_manager: Node2D = $BuildManager
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	GameManager.reset()
	wave_manager.setup(path)
	build_manager.setup(path, towers)

	# Propojení HUD → herní systémy.
	hud.build_selection_changed.connect(build_manager.set_build_selection)
	hud.start_pressed.connect(_on_start_pressed)

	# Aktualizace čísla vlny v HUD.
	wave_manager.wave_started.connect(hud.set_wave)

	queue_redraw()

func _on_start_pressed() -> void:
	wave_manager.start()

func _unhandled_input(event: InputEvent) -> void:
	# Restart hry klávesou R.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()

func _draw() -> void:
	# Vykreslí cestu jako širokou čáru, aby hráč viděl, kudy jdou nepřátelé.
	if path != null and path.curve != null:
		var pts := path.curve.get_baked_points()
		if pts.size() > 1:
			draw_polyline(pts, Color(0.78, 0.66, 0.45), 40.0)
