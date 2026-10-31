extends CanvasLayer
## AUTOLOAD (Singleton) olarak eklenmelidir:
## Project Settings > Autoload
##   Path: res://Scripts/scene_transition.gd
##   Node Name: SceneTransition
##
## Tam ekranı kaplayan, görünmez bir ColorRect ile ekranı karartıp
## açar; karanlık en yüksek seviyedeyken hedef sahneye geçer.
## Üst üste birden fazla geçiş tetiklenmesini is_transitioning ile engeller.

signal transition_finished

@export var fade_duration: float = 0.4

var is_transitioning: bool = false

var _color_rect: ColorRect

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_color_rect = ColorRect.new()
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_color_rect)

func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true

	# 1) Ekranı yumuşakça karart.
	var tween_in := create_tween()
	tween_in.tween_property(_color_rect, "color:a", 1.0, fade_duration)
	await tween_in.finished

	# 2) Ekran tamamen karardıktan sonra sahneyi değiştir.
	get_tree().change_scene_to_file(scene_path)

	# Yeni sahnenin _ready()'sinin tamamlanmasını garantilemek için
	# bir sonraki frame'leri bekle.
	await get_tree().process_frame
	await get_tree().process_frame

	# 3) Ekranı tekrar aç.
	var tween_out := create_tween()
	tween_out.tween_property(_color_rect, "color:a", 0.0, fade_duration)
	await tween_out.finished

	is_transitioning = false
	transition_finished.emit()
