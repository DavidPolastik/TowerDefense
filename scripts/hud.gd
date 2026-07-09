extends CanvasLayer
# spodni lista (zlato, zivoty, vlna, tlacitka) + obrazovka konce

signal build_selection_changed(type: int)   # -1 nic, 0 zakladni, 1 silna
signal start_pressed()

@onready var level_label: Label = $Bar/Row/Stats/LevelLabel
@onready var gold_label: Label = $Bar/Row/Stats/InfoRow/GoldRow/GoldLabel
@onready var lives_label: Label = $Bar/Row/Stats/InfoRow/LivesRow/LivesLabel
@onready var wave_label: Label = $Bar/Row/Stats/WaveLabel
@onready var basic_button: Button = $Bar/Row/BasicButton
@onready var heavy_button: Button = $Bar/Row/HeavyButton
@onready var start_button: Button = $Bar/Row/StartButton
@onready var menu_bar_button: Button = $Bar/Row/MenuBarButton
@onready var overlay: Control = $Overlay
@onready var message_label: Label = $Overlay/Center/Card/VBox/MessageLabel
@onready var next_button: Button = $Overlay/Center/Card/VBox/Buttons/NextButton
@onready var retry_button: Button = $Overlay/Center/Card/VBox/Buttons/RetryButton
@onready var menu_button: Button = $Overlay/Center/Card/VBox/Buttons/MenuButton

var _wave_total: int = 0

func _ready() -> void:
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.game_over.connect(_on_game_over)
	_on_gold_changed(GameManager.gold)
	_on_lives_changed(GameManager.lives)
	overlay.visible = false
	basic_button.toggled.connect(_on_basic_toggled)
	heavy_button.toggled.connect(_on_heavy_toggled)
	start_button.pressed.connect(_on_start_pressed)
	menu_bar_button.pressed.connect(_on_menu)
	next_button.pressed.connect(_on_next)
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)

func set_level_info(level_name: String, total: int) -> void:
	level_label.text = level_name
	_wave_total = total
	set_wave(0)

func set_wave(n: int) -> void:
	wave_label.text = "Vlna: %d/%d" % [n, _wave_total]

func _on_basic_toggled(pressed: bool) -> void:
	if pressed:
		heavy_button.set_pressed_no_signal(false)
		build_selection_changed.emit(0)
	elif not heavy_button.button_pressed:
		build_selection_changed.emit(-1)

func _on_heavy_toggled(pressed: bool) -> void:
	if pressed:
		basic_button.set_pressed_no_signal(false)
		build_selection_changed.emit(1)
	elif not basic_button.button_pressed:
		build_selection_changed.emit(-1)

func _on_start_pressed() -> void:
	start_button.disabled = true
	start_pressed.emit()

func _on_gold_changed(amount: int) -> void:
	gold_label.text = str(amount)

func _on_lives_changed(amount: int) -> void:
	lives_label.text = str(amount)

func _on_game_over(victory: bool) -> void:
	message_label.text = "VÍTĚZSTVÍ!" if victory else "PROHRA"
	message_label.modulate = Color(0.4, 1, 0.5) if victory else Color(1, 0.4, 0.4)
	next_button.visible = victory and Levels.has_next()
	overlay.visible = true

func _on_next() -> void:
	if Levels.has_next():
		Levels.current += 1
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_retry() -> void:
	get_tree().reload_current_scene()

func _on_menu() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
