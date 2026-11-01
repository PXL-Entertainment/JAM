extends Area2D

@export var texture_idle: Texture2D
@export var texture_active: Texture2D
@export var accepted_items: Array[String] = ["Çöp1", "Çöp2", "Çöp3", "Çöp4"]   # örn. ["Elma", "Armut", "Muz", "Kiraz"]
@export var required_count: int = 4
@export var unique_items: bool = true            # true: listedeki her isim sadece 1 kez atılabilir

@export var reward_item_scene: PackedScene       # spawn olacak item sahnesi
@export var spawn_offset: Vector2 = Vector2(0, -40)

var given_items: Array[String] = []
var completed := false

func _ready() -> void:
	add_to_group("machines")
	if texture_idle:
		$RecyleMachineSprite.texture = texture_idle

func can_accept(item: Node) -> bool:
	if completed:
		return false

	var item_key: String = str(item.item_name).strip_edges().to_lower()

	# Bu isim daha önce atıldıysa tekrar kabul etme
	if unique_items and given_items.has(item_key):
		return false

	# Liste boşsa her item kabul
	if accepted_items.is_empty():
		return true

	for n in accepted_items:
		if n.strip_edges().to_lower() == item_key:
			return true

	print("Makine bu item'ı kabul etmedi: '", item.item_name, "'")   # teşhis için
	return false

func accept_item(item: Node) -> void:
	given_items.append(str(item.item_name).strip_edges().to_lower())
	item.queue_free()
	_pulse()

	if given_items.size() >= required_count:
		completed = true
		if texture_active:
			$RecyleMachineSprite.texture = texture_active
		_spawn_reward()

func _spawn_reward() -> void:
	if reward_item_scene == null:
		push_warning("Machine: reward_item_scene atanmamış!")
		return

	var new_item := reward_item_scene.instantiate()
	get_parent().add_child(new_item)
	new_item.global_position = global_position + spawn_offset

	if new_item is RigidBody2D:
		new_item.linear_velocity = Vector2(0, -150)

func _pulse() -> void:
	var tween := create_tween()
	tween.tween_property($RecyleMachineSprite, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property($RecyleMachineSprite, "scale", Vector2.ONE, 0.08)
