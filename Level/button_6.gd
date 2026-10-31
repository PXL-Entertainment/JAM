extends Button

const SceneFader := preload("res://Scripts/scene_fader.gd")

@export_file("*.tscn") var target_scene: String = "res://player/node_2d.tscn"
@export var fade_duration: float = 0.5

func _ready() -> void:
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if target_scene == "":
		return
	if not ResourceLoader.exists(target_scene):
		return

	var fader := SceneFader.new()
	get_tree().root.add_child(fader)
	fader.go_to(target_scene, fade_duration)
