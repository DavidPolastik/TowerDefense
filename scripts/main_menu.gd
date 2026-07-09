extends Control
## Hlavní menu hry.

func _ready() -> void:
	Engine.time_scale = 1.0   # v menu vždy normální rychlost
	$Center/Card/VBox/PlayButton.pressed.connect(_on_play)
	$Center/Card/VBox/SettingsButton.pressed.connect(_on_settings)
	$Center/Card/VBox/QuitButton.pressed.connect(_on_quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit() -> void:
	get_tree().quit()
