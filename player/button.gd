extends Button

## Taşınacak node (oyuncu vb.)
@export var mover: Node2D
## Gidilecek yer: sahneye koyduğun bir Marker2D / Node2D
@export var target_marker: Marker2D
## Marker yoksa bu koordinat kullanılır (global)
@export var target_position: Vector2 = Vector2.ZERO
@export var fade_duration: float = 0.5

var _busy := false

func _ready() -> void:
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if _busy or mover == null:
		return
	_busy = true

	var dest: Vector2 = target_marker.global_position if target_marker else target_position

	# Geçici siyah ekran (fade)
	var layer := CanvasLayer.new()
	layer.layer = 100
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	get_tree().root.add_child(layer)

	var tw := create_tween()
	tw.tween_property(rect, "modulate:a", 1.0, fade_duration)
	tw.tween_callback(func(): mover.global_position = dest)
	tw.tween_property(rect, "modulate:a", 0.0, fade_duration)
	tw.tween_callback(func():
		layer.queue_free()
		_busy = false
	);
