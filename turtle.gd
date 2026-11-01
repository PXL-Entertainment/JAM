extends Area2D

@export var texture_with_bottle: Texture2D
@export var texture_without_bottle: Texture2D

@onready var mouth_point: Marker2D = $MouthPoint
@onready var bottle: RigidBody2D = $MouthPoint/Item

var remaining: Array = []
var bottle_taken := false

func _ready() -> void:
	add_to_group("interactables")

	# Önceden temizlenen sprite'ları baştan kaldır (sondan başa doğru temizleniyordu)
	var all := $Webs.get_children()
	var left: int = max(all.size() - GameState2.turtle_blockers_cleared, 0)
	for i in range(left, all.size()):
		all[i].queue_free()
	remaining = all.slice(0, left)

	# Şişe daha önce alındıysa tekrar çıkmasın
	if GameState2.turtle_bottle_taken:
		bottle_taken = true
		bottle.queue_free()
		if texture_without_bottle:
			$TurtleSprite.texture = texture_without_bottle
		return

	if texture_with_bottle:
		$TurtleSprite.texture = texture_with_bottle

	bottle.freeze = true
	_set_bottle_pickable(remaining.is_empty())

func can_interact() -> bool:
	return not remaining.is_empty()

func interact() -> void:
	if remaining.is_empty():
		return

	var s: Node = remaining.pop_back()
	GameState2.turtle_blockers_cleared += 1

	var tween := create_tween()
	tween.tween_property(s, "modulate:a", 0.0, 0.15)
	tween.tween_callback(s.queue_free)

	if remaining.is_empty():
		_set_bottle_pickable(true)

func _set_bottle_pickable(value: bool) -> void:
	bottle.get_node("CollisionShape2D").set_deferred("disabled", not value)

func _process(_delta: float) -> void:
	if bottle_taken:
		return
	# Şişe MouthPoint'ten çıktıysa oyuncu almıştır
	if not is_instance_valid(bottle) or bottle.get_parent() != mouth_point:
		bottle_taken = true
		GameState2.turtle_bottle_taken = true
		if texture_without_bottle:
			$TurtleSprite.texture = texture_without_bottle
