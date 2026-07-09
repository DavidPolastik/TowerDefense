extends Control
## Nastavení – hlasitost a celá obrazovka (ukládá se přes Levels).

const SPEEDS := [1.0, 2.0, 3.0]

func _ready() -> void:
	Engine.time_scale = 1.0
	var vol: HSlider = $Center/Card/VBox/VolumeRow/VolumeSlider
	vol.value = Levels.volume
	vol.value_changed.connect(_on_volume)
	var speed: OptionButton = $Center/Card/VBox/SpeedRow/SpeedOption
	speed.add_item("1× (normální)")
	speed.add_item("2× (rychle)")
	speed.add_item("3× (velmi rychle)")
	speed.selected = SPEEDS.find(Levels.game_speed) if SPEEDS.has(Levels.game_speed) else 0
	speed.item_selected.connect(_on_speed)
	var fs: CheckButton = $Center/Card/VBox/FullscreenCheck
	fs.button_pressed = Levels.fullscreen
	fs.toggled.connect(_on_fullscreen)
	$Center/Card/VBox/BackButton.pressed.connect(_on_back)

func _on_speed(index: int) -> void:
	Levels.set_game_speed(SPEEDS[index])

func _on_volume(v: float) -> void:
	Levels.set_volume(v)

func _on_fullscreen(on: bool) -> void:
	Levels.set_fullscreen(on)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
