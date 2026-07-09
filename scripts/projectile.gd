extends Node2D
## Projectile – projektil vystřelený věží.
## Letí přímo k cíli; při dosažení mu způsobí poškození a zanikne.

@export var speed: float = 420.0

var _target: Node2D = null
var _damage: int = 0

## Nastaví cíl a poškození (volá věž při výstřelu).
func setup(target: Node2D, damage: int) -> void:
	_target = target
	_damage = damage

func _physics_process(delta: float) -> void:
	# Pokud cíl už neexistuje (byl zabit jiným projektilem), zanikni.
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	var step := speed * delta
	if dist <= step:
		# Zásah.
		if _target.has_method("take_damage"):
			_target.take_damage(_damage)
		queue_free()
		return
	global_position += to_target / dist * step
