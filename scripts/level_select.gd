extends Control
# vyber urovne - tlacitka se generuji podle dat, zamcene jsou neaktivni

func _ready() -> void:
	Engine.time_scale = 1.0
	var container: VBoxContainer = $Center/Card/VBox/Levels
	for i in Levels.level_count():
		var lvl: Dictionary = Levels.get_level(i)
		var unlocked: bool = Levels.is_unlocked(i)
		var b := Button.new()
		b.text = lvl["name"] if unlocked else lvl["name"] + "   (zamčeno)"
		b.custom_minimum_size = Vector2(340, 0)
		b.disabled = not unlocked
		b.pressed.connect(_on_level.bind(i))
		container.add_child(b)
	$Center/Card/VBox/BackButton.pressed.connect(_on_back)

func _on_level(i: int) -> void:
	Levels.current = i
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
