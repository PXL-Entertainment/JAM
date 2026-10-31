extends RigidBody2D

@export var item_name: String = "Elma"
@export var texture: Texture2D

func _ready() -> void:
	add_to_group("items")
	lock_rotation = true
	if texture:
		%ItemSprite2.texture = texture

func set_held(held: bool) -> void:
	# Taşınırken fizik kapanır, bırakılınca tekrar açılır
	freeze = held
	$CollisionShape2D2.set_deferred("disabled", held)
	if not held:
		linear_velocity = Vector2.ZERO
