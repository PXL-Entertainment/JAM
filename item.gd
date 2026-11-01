extends RigidBody2D
@export var item_name: String = "Elma"
@export var texture: Texture2D

# --- Interact ikonu (yaklasinca cikan gosterge) ---
@export var interact_icon_texture: Texture2D
@export var interact_icon_size: Vector2 = Vector2(48, 48)
@export var interact_icon_offset: Vector2 = Vector2(0, -60)
@export var interact_range: float = 80.0

var _item_key: String = ""
var _interact_icon: TextureRect

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
	_interact_icon = _build_interact_icon()
	add_child(_interact_icon)

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


func _process(_delta: float) -> void:
	if not is_instance_valid(_interact_icon):
		return

	# Tasiniyorken (elde) ikonu hic gosterme.
	if freeze:
		_interact_icon.visible = false
		return

	var nearest_player: Node2D = _find_nearest_player()
	if nearest_player == null:
		_interact_icon.visible = false
		return

	var dist := global_position.distance_to(nearest_player.global_position)
	if dist <= interact_range:
		_interact_icon.visible = true
		_interact_icon.global_position = global_position + interact_icon_offset - _interact_icon.size / 2.0
	else:
		_interact_icon.visible = false


func _find_nearest_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	var nearest: Node2D = null
	var nearest_dist := INF
	for p in players:
		if p is Node2D:
			var d := global_position.distance_to(p.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = p
	return nearest


func _build_interact_icon() -> TextureRect:
	var icon := TextureRect.new()
	icon.size = interact_icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if interact_icon_texture:
		icon.texture = interact_icon_texture
	icon.visible = false
	return icon


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
