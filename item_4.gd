extends RigidBody2D
@export var item_name: String = "Çöp4"
@export var texture: Texture2D

var _item_key: String = ""

func _ready() -> void:
	add_to_group("items")
	lock_rotation = true

	if has_meta("item_key"):
		_item_key = get_meta("item_key")
	else:
		var scene_path := ""
		if get_tree().current_scene:
			scene_path = get_tree().current_scene.scene_file_path
		_item_key = scene_path + "::" + str(get_path())
		set_meta("item_key", _item_key)

	_apply_texture()

	if get_meta("carried_instance", false):
		return

	var current_scene_path := ""
	if get_tree().current_scene:
		current_scene_path = get_tree().current_scene.scene_file_path

	var loc = GameState.get_item_location(_item_key)
	if loc == null:
		GameState.set_item_location(_item_key, current_scene_path, position)
		return

	if loc.get("held", false):
		queue_free()
		return

	if loc.get("scene_path", "") != current_scene_path:
		queue_free()
		return

	position = loc.get("position", position)


func _apply_texture() -> void:
	if not texture:
		return
	var sprite := find_child("ItemSprite2", true, false)
	if sprite == null:
		var found := find_children("*", "Sprite2D", true, false)
		if found.size() > 0:
			sprite = found[0]
	if sprite:
		sprite.texture = texture


func set_held(held: bool) -> void:
	freeze = held
	$CollisionShape2D2.set_deferred("disabled", held)
	if not held:
		linear_velocity = Vector2.ZERO
		var scene_path := ""
		if get_tree().current_scene:
			scene_path = get_tree().current_scene.scene_file_path
		GameState.set_item_location(_item_key, scene_path, global_position)
	else:
		GameState.mark_item_held(_item_key)
