extends Area2D
## node_2d.tscn içindeki Area2D (ElevatorArea / elevator 2d) node'una eklenir.
##
## BU VERSİYON AUTOLOAD GEREKTİRMEZ. Project Settings > Autoload ile hiç
## uğraşmana gerek yok — geçiş sistemini (SceneTransition) ilk ihtiyaç
## duyulduğunda kendisi otomatik olarak sahne köküne (root) ekliyor.
##
## Gereksinimler (sadece bunlar):
## 1) Player node'u "player" grubuna eklenmiş olmalı (Node sekmesi > Groups).
## 2) Input Map'te "interact" adında, E tuşuna bağlı bir aksiyon tanımlı olmalı.
## 3) res://Scripts/scene_transition.gd dosyası mevcut olmalı (script içeriği
##    aynı kalıyor, sadece Autoload'a eklenmesine gerek yok).
## 4) Bu Area2D'ye bir CollisionShape2D (RectangleShape2D) child olarak
##    eklenmeli; boyutu Inspector'dan ayarlanabilir.
## 5) Area2D'nin Collision Mask'ı, oyuncunun bulunduğu fizik katmanını kapsamalı.

const SCENE_TRANSITION_SCRIPT := preload("res://Scripts/scene_transition.gd")
const TRANSITION_NODE_NAME := "__SceneTransition"

@export var target_scene_path: String = "res://Level/elevator.tscn"
@export var indicator_offset: Vector2 = Vector2(0, -48)

var _player_in_area: bool = false
var _current_player: Node2D = null
var _e_indicator: Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_e_indicator = _build_indicator()
	add_child(_e_indicator)

func _process(_delta: float) -> void:
	if _player_in_area and is_instance_valid(_current_player):
		_e_indicator.global_position = (
			_current_player.global_position
			+ indicator_offset
			- _e_indicator.size / 2.0
		)

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_area:
		return
	if event.is_action_pressed("interact"):
		_try_trigger_elevator()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_area = true
	_current_player = body
	_e_indicator.visible = true

func _on_body_exited(body: Node) -> void:
	if body != _current_player:
		return
	_player_in_area = false
	_current_player = null
	_e_indicator.visible = false

func _try_trigger_elevator() -> void:
	var transition := _get_transition()
	if transition.is_transitioning:
		return
	_player_in_area = false
	_e_indicator.visible = false
	transition.change_scene(target_scene_path)

## Geçiş sistemini sahne köküne (SceneTree root) bir kere ekler, sonraki
## çağrılarda zaten var olanı bulup döndürür. Autoload'a hiç ihtiyaç yok.
func _get_transition() -> Node:
	var root := get_tree().root
	var existing := root.get_node_or_null(TRANSITION_NODE_NAME)
	if existing:
		return existing
	var instance: Node = SCENE_TRANSITION_SCRIPT.new()
	instance.name = TRANSITION_NODE_NAME
	root.add_child(instance)
	return instance

func _build_indicator() -> Label:
	var label := Label.new()
	label.text = "E"
	label.size = Vector2(32, 32)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.visible = false
	return label
