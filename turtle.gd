extends Area2D

@export var texture_with_bottle: Texture2D
@export var texture_without_bottle: Texture2D

# --- Kalp animasyonu ---
@export var heart_sheet: Texture2D
@export var heart_frame_count: int = 10
@export var heart_fps: float = 5.0                 # dusurdukce animasyon yavaslar/uzar
@export var heart_offset: Vector2 = Vector2(0, -70)
@export var heart_last_frame_hold: float = 8.0      # son kare, digerlerine gore kac kat uzun gorunsun

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
		GameState2.fish_revealed = true
		if texture_without_bottle:
			$TurtleSprite.texture = texture_without_bottle
		_play_heart_animation()

func _play_heart_animation() -> void:
	if heart_sheet == null:
		return

	var anim := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation("beat")
	frames.set_animation_loop("beat", false)
	frames.set_animation_speed("beat", heart_fps)

	var frame_w: int = int(heart_sheet.get_width() / float(heart_frame_count))
	var frame_h: int = heart_sheet.get_height()

	for i in range(heart_frame_count):
		var atlas := AtlasTexture.new()
		atlas.atlas = heart_sheet
		atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)

		var duration := 1.0
		if i == heart_frame_count - 1:
			duration = heart_last_frame_hold

		frames.add_frame("beat", atlas, duration)

	anim.sprite_frames = frames
	anim.animation = "beat"
	anim.position = heart_offset
	anim.z_index = 10

	add_child(anim)
	anim.play("beat")
	anim.animation_finished.connect(anim.queue_free)
