extends RigidBody2D
@export var item_name: String = "Elma"
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

	# Oyuncunun elinde tasinan kopya ise konum kontrolune hic girme.
	if get_meta("carried_instance", false):
		return

	var current_scene_path := ""
	if get_tree().current_scene:
		current_scene_path = get_tree().current_scene.scene_file_path

	var loc = GameState.get_item_location(_item_key)
	
	# EĞER EŞYA DAHA ÖNCE YÜKLENMİŞSE (GameState'te kaydı varsa):
	# Bu kata ikinci kez gelindiğinde tekrar spawn olmaması için kendini hemen siler.
	if loc != null:
		queue_free()
		return

	# EŞYA İLK DEFA GÖRÜLÜYORSA:
	# GameState'e kaydedilir ve sahnedeki yerinde kalır.
	GameState.set_item_location(_item_key, current_scene_path, position)


func _apply_texture() -> void:
	if not texture:
		return
	var sprite := find_child("ItemSprite", true, false)
	if sprite == null:
		var found := find_children("*", "Sprite2D", true, false)
		if found.size() > 0:
			sprite = found[0]
	if sprite:
		sprite.texture = texture


func set_held(held: bool) -> void:
	# Tasinirken fizik kapanir, birakilinca tekrar acilir
	freeze = held
	$CollisionShape2D.set_deferred("disabled", held)
	if not held:
		linear_velocity = Vector2.ZERO
		var scene_path := ""
		if get_tree().current_scene:
			scene_path = get_tree().current_scene.scene_file_path
		GameState.set_item_location(_item_key, scene_path, global_position)
	else:
		GameState.mark_item_held(_item_key)
