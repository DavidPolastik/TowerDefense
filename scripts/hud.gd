extends CanvasLayer
## HUD – uživatelské rozhraní (spodní lišta).
## Zobrazuje zlato, životy a vlnu; nabízí výběr dvou typů věží a start vln.
## Reaguje na signály GameManageru (nemá přímé vazby na herní logiku).

# type: -1 = nic (stavba vypnutá), 0 = základní věž, 1 = silná věž
signal build_selection_changed(type: int)
signal start_pressed()

@onready var gold_label: Label = $Bar/Row/Stats/GoldLabel
@onready var lives_label: Label = $Bar/Row/Stats/LivesLabel
@onready var wave_label: Label = $Bar/Row/Stats/WaveLabel
@onready var basic_button: Button = $Bar/Row/BasicButton
@onready var heavy_button: Button = $Bar/Row/HeavyButton
@onready var start_button: Button = $Bar/Row/StartButton
@onready var message_label: Label = $CenterMessage

func _ready() -> void:
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.game_over.connect(_on_game_over)
	_on_gold_changed(GameManager.gold)
	_on_lives_changed(GameManager.lives)
	set_wave(0)
	message_label.visible = false
	basic_button.toggled.connect(_on_basic_toggled)
	heavy_button.toggled.connect(_on_heavy_toggled)
	start_button.pressed.connect(_on_start_pressed)

## Aktualizuje zobrazené číslo vlny (napojeno na WaveManager).
func set_wave(n: int) -> void:
	wave_label.text = "Vlna: %d" % n

# Tlačítka pro výběr věže se chovají jako přepínače – aktivní může být jen jedno.
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
	gold_label.text = "Zlato: %d" % amount

func _on_lives_changed(amount: int) -> void:
	lives_label.text = "Životy: %d" % amount

func _on_game_over(victory: bool) -> void:
	message_label.visible = true
	if victory:
		message_label.text = "VÝHRA!\n(R = restart)"
	else:
		message_label.text = "PROHRA\n(R = restart)"
