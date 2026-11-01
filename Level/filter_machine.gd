extends Area2D

@export var texture_idle: Texture2D
@export var texture_active: Texture2D
@export var accepted_items: Array[String] = ["ClorineBottle", "BigFilter", "MicroFilter"]
@export var required_count: int = 3
@export var unique_items: bool = true            # true: listedeki her isim sadece 1 kez atılabilir

@export var reward_item_scene: PackedScene       # spawn olacak item sahnesi
@export var spawn_offset: Vector2 = Vector2(0, -40)

signal machine_completed                         # istersen başka düğümler buna bağlanabilir

var completed := false

func _ready() -> void:
	add_to_group("machines")

	# Daha önce tamamlandıysa (sahne yeniden yüklenmiş olabilir) son hâlde başla
	if GameState2.filter_machine_completed:
		completed = true
		if texture_active:
			%Sprite2D.texture = texture_active
		return

	if texture_idle:
		%Sprite2D.texture = texture_idle

func can_accept(item: Node) -> bool:
	if completed:
		return false

	var item_key: String = str(item.item_name).strip_edges().to_lower()

	# Bu isim daha önce atıldıysa tekrar kabul etme
	if unique_items and GameState2.filter_given_items.has(item_key):
		return false

	if accepted_items.is_empty():
		return true

	for n in accepted_items:
		if n.strip_edges().to_lower() == item_key:
			return true

	print("Makine bu item'ı kabul etmedi: '", item.item_name, "'")
	return false

func accept_item(item: Node) -> void:
	$AcceptSound.play()
	GameState2.filter_given_items.append(str(item.item_name).strip_edges().to_lower())
	print("Verilen: ", GameState2.filter_given_items.size(), "/", required_count, " -> ", GameState2.filter_given_items)
	item.queue_free()
	_pulse()

	if GameState2.filter_given_items.size() >= required_count:
		_complete()


func _complete() -> void:
	completed = true
	GameState2.filter_machine_completed = true   # completed check
	GameState2.ocean_color_changed = true
	GameState2.ocean_color = Color("00a0ff")

	if texture_active:
		%Sprite2D.texture = texture_active

	machine_completed.emit()
	print("Filter Machine tamamlandı")
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
	tween.tween_property(%Sprite2D, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(%Sprite2D, "scale", Vector2.ONE, 0.08)
