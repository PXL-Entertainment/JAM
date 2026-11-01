
extends Control

@export_file("*.tscn") var next_scene: String = "res://MainMenu.tscn"   # kendi ilk sahnenin yolunu yaz
@export var fade_in_time: float = 1.0
@export var hold_time: float = 1.5
@export var fade_out_time: float = 1.0

@onready var logo: TextureRect = $Logo

func _ready() -> void:
	logo.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, fade_in_time)    # belir
	tween.tween_interval(hold_time)                                 # bekle
	tween.tween_property(logo, "modulate:a", 0.0, fade_out_time)   # kaybol
	await tween.finished

	_go_next()

func _unhandled_input(event: InputEvent) -> void:
	# Tıklama ya da tuşla atlama
	if event is InputEventKey and event.pressed:
		_go_next()
	elif event is InputEventMouseButton and event.pressed:
		_go_next()

func _go_next() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
