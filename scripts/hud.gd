extends CanvasLayer
## HUD – uživatelské rozhraní.
## Zobrazuje zlato, životy a číslo vlny; nabízí tlačítka Stavět věž a Start.
## Reaguje na signály GameManageru (nemá přímé vazby na herní logiku).

signal build_button_toggled(enabled: bool)
signal start_pressed()

@onready var gold_label: Label = $Panel/VBox/GoldLabel
@onready var lives_label: Label = $Panel/VBox/LivesLabel
@onready var wave_label: Label = $Panel/VBox/WaveLabel
@onready var build_button: Button = $Panel/VBox/BuildButton
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var message_label: Label = $CenterMessage

func _ready() -> void:
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.game_over.connect(_on_game_over)
	_on_gold_changed(GameManager.gold)
	_on_lives_changed(GameManager.lives)
	set_wave(0)
	message_label.visible = false
	build_button.toggled.connect(_on_build_toggled)
	start_button.pressed.connect(_on_start_pressed)

## Aktualizuje zobrazené číslo vlny (napojeno na WaveManager).
func set_wave(n: int) -> void:
	wave_label.text = "Vlna: %d" % n

func _on_build_toggled(pressed: bool) -> void:
	build_button_toggled.emit(pressed)

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
