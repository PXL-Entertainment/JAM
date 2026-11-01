extends CanvasLayer
## Bagimsiz, tek kullanimlik karartma/sahne-gecis yardimcisi.
## AUTOLOAD DEGILDIR. Her tetiklemede yeni bir ornek olusturulup
## dogrudan get_tree().root altina eklenir.

var _rect: ColorRect

func _ready() -> void:
	layer = 100
	_rect = ColorRect.new()
	_rect.color = Color.BLACK
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_rect.modulate.a = 0.0
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)

func go_to(target_scene_path: String, fade_duration: float = 0.5) -> void:
	var tree := get_tree()

	var tween_out := create_tween()
	tween_out.tween_property(_rect, "modulate:a", 1.0, fade_duration)
	await tween_out.finished

	if not ResourceLoader.exists(target_scene_path):
		push_error("Sahne bulunamadi: %s" % target_scene_path)
		queue_free()
		return

	# Bu odada serbest duran (elde olmayan) esyalari, sahne kapanmadan once
	# guvenle "park et" ki yok olmasinlar; bu odaya geri donulunce otomatik
	# olarak eski yerlerinde cikacaklar.
	if tree.current_scene:
		GameState.park_loose_items(tree.current_scene)

	var err := tree.change_scene_to_file(target_scene_path)
	if err != OK:
		push_error("Sahne degistirilemedi, kod: %s" % err)
		queue_free()
		return

	await tree.process_frame

	var tween_in := create_tween()
	tween_in.tween_property(_rect, "modulate:a", 0.0, fade_duration)
	await tween_in.finished

	queue_free()
