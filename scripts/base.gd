extends Sprite2D
## Base – hrad (základna). Zobrazuje ukazatel životů hráče.
## Životy drží GameManager; tady je jen vykreslujeme jako health bar.

func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)
	queue_redraw()

func _on_lives_changed(_amount: int) -> void:
	queue_redraw()

func _draw() -> void:
	# Ukazatel životů nad hradem (lokální souřadnice spritu, střed v 0,0).
	var max_lives: int = max(1, GameManager.start_lives)
	var ratio: float = clampf(float(GameManager.lives) / float(max_lives), 0.0, 1.0)
	var bar_w := 120.0
	var bar_h := 16.0
	var top_left := Vector2(-bar_w / 2.0, -86.0)
	var fill: Color
	if ratio < 0.34:
		fill = Color(0.9, 0.3, 0.25)
	elif ratio < 0.67:
		fill = Color(0.9, 0.75, 0.2)
	else:
		fill = Color(0.3, 0.85, 0.35)
	draw_rect(Rect2(top_left, Vector2(bar_w, bar_h)), Color(0.1, 0.1, 0.1))
	draw_rect(Rect2(top_left, Vector2(bar_w * ratio, bar_h)), fill)
	draw_rect(Rect2(top_left, Vector2(bar_w, bar_h)), Color(0, 0, 0, 0.7), false, 2.0)
