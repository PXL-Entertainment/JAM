extends Area2D

@export var texture_idle: Texture2D
@export var texture_active: Texture2D
@export var accepted_item: String = ""
@export var required_count: int = 4

@export var reward_item_scene: PackedScene          # spawn olacak item sahnesi
@export var spawn_offset: Vector2 = Vector2(0, -40) # makineye gore cikis noktasi

var current_count := 0
var completed := false

var _machine_key: String = ""

func _ready() -> void:
	add_to_group("machines")

	var scene_path := ""
	if get_tree().current_scene:
		scene_path = get_tree().current_scene.scene_file_path
	_machine_key = scene_path + "::" + str(get_path())

	# Daha once bu makineye esya atildiysa, durumu geri yukle.
	var saved = GameState.get_machine_state(_machine_key)
	if saved != null:
		current_count = saved.get("current_count", 0)
		completed = saved.get("completed", false)

	if texture_idle:
		%RecyleMachineSprite.texture = texture_idle
	if completed and texture_active:
		%RecyleMachineSprite.texture = texture_active

func can_accept(item: Node) -> bool:
	if completed:
		return false
	return accepted_item == "" or item.item_name == accepted_item

func accept_item(item: Node) -> void:
	item.queue_free()
	current_count += 1
	%RecyleMachineSprite.pickup()

	if current_count >= required_count:
		completed = true
		if texture_active:
			%RecyleMachineSprite.texture = texture_active
		GameState.save_machine_state(_machine_key, current_count, completed)
		_spawn_reward()
	else:
		GameState.save_machine_state(_machine_key, current_count, completed)

func _spawn_reward() -> void:
	if reward_item_scene == null:
		push_warning("Machine: reward_item_scene atanmamis!")
		return

	var new_item := reward_item_scene.instantiate()
	get_parent().add_child(new_item)
	new_item.global_position = global_position + spawn_offset

	# Item RigidBody2D oldugu icin hafifce yukari firlatabiliriz
	if new_item is RigidBody2D:
		new_item.linear_velocity = Vector2(0, -150)
