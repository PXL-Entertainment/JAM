extends Area2D

const SceneFader := preload("res://Scripts/scene_fader.gd")

@export_file("*.tscn") var target_scene_path: String = "res://Level/elevator.tscn"
@export var indicator_offset: Vector2 = Vector2(0, -100)
@export var fade_duration: float = 0.5
@export var e_icon_texture: Texture2D   # <-- Arkadasinin cizdigi keycap/button görseli buraya atanacak
@export var icon_size: Vector2 = Vector2(48, 48)  # Gorselin ekranda ne kadar buyuk gorunecegi

var _player_in_area: bool = false
var _current_player: Node2D = null
var _e_indicator: TextureRect
var _is_transitioning: bool = false

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
	if event.is_action_pressed("interaction"):
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
	if _is_transitioning:
		return
	_is_transitioning = true
	_player_in_area = false
	_e_indicator.visible = false

	var fader := SceneFader.new()
	get_tree().root.add_child(fader)
	fader.go_to(target_scene_path, fade_duration)

func _build_indicator() -> TextureRect:
	var icon := TextureRect.new()
	icon.size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if e_icon_texture:
		icon.texture = e_icon_texture
	icon.visible = false
	return icon
