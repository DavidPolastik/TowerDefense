extends Node2D
## Tower – věž (bojový systém).
## Najde nejbližšího nepřítele v dosahu a v intervalu na něj střílí projektily.
## Nepřátele hledá ve skupině "enemies" podle vzdálenosti (bez fyzikálních těles).

@export var range_radius: float = 160.0   # dosah v pixelech
@export var fire_rate: float = 1.2        # výstřelů za sekundu
@export var damage: int = 12
@export var projectile_scene: PackedScene

var _cooldown: float = 0.0

func _ready() -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown <= 0.0:
		var target := _find_target()
		if target != null:
			_fire(target)
			_cooldown = 1.0 / fire_rate

## Najde nejbližšího nepřítele v dosahu.
func _find_target() -> Node2D:
	var best: Node2D = null
	var best_dist := range_radius
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		var d := global_position.distance_to(enemy.global_position)
		if d <= best_dist:
			best_dist = d
			best = enemy
	return best

func _fire(target: Node2D) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.setup(target, damage)
	# Přidáme projektil do kontejneru "Projectiles", jinak k rodiči věže.
	var container := get_tree().current_scene.get_node_or_null("Projectiles")
	if container != null:
		container.add_child(projectile)
	else:
		get_parent().add_child(projectile)

func _draw() -> void:
	# Vizualizace dosahu věže.
	draw_circle(Vector2.ZERO, range_radius, Color(0.3, 0.6, 1.0, 0.07))
	draw_arc(Vector2.ZERO, range_radius, 0.0, TAU, 48, Color(0.3, 0.6, 1.0, 0.25), 1.5)
