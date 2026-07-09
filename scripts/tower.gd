extends Node2D
# vez - zamiri nejblizsiho nepritele v dosahu a strili na nej

@export var range_radius: float = 160.0
@export var fire_rate: float = 1.2
@export var damage: int = 12
@export var projectile_scene: PackedScene
@export var is_heavy: bool = false

var _cooldown: float = 0.0
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("towers")
	queue_redraw()

func _physics_process(delta: float) -> void:
	var target := _find_target()
	if target != null:
		# otoc hlaven na cil
		var dir := target.global_position - global_position
		sprite.rotation = dir.angle() + PI / 2.0
	_cooldown -= delta
	if _cooldown <= 0.0 and target != null:
		_fire(target)
		_cooldown = 1.0 / fire_rate

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
	var container := get_tree().current_scene.get_node_or_null("Projectiles")
	if container != null:
		container.add_child(projectile)
	else:
		get_parent().add_child(projectile)
	if is_heavy:
		Sfx.play_shot_heavy()
	else:
		Sfx.play_shot()

func _draw() -> void:
	# kruh dosahu
	draw_circle(Vector2.ZERO, range_radius, Color(0.3, 0.6, 1.0, 0.07))
	draw_arc(Vector2.ZERO, range_radius, 0.0, TAU, 48, Color(0.3, 0.6, 1.0, 0.25), 1.5)
