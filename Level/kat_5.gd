extends Node2D

@onready var ocean: Sprite2D = $Ocean
@onready var trash_nodes = [$Trash4]
@onready var hidden_fish = [$Fish3]  # Fish3'ün altındaki çocuklar da gizlenir

const ELEVATOR_SCENE := "res://Level/elevator.tscn" # kendi yolunu yaz

var credits_started := false

func _ready():
	print("ocean: ", GameState2.filter_machine_completed,
		" | trash: ", GameState2.trash_cleaned,
		" | fish: ", GameState2.fish_revealed)
	apply_state()
func _process(delta: float) -> void:
	check_credits()

func apply_state():
	if GameState2.ocean_color_changed:
		ocean.modulate = GameState2.ocean_color

	if GameState2.trash_cleaned:
		for t in trash_nodes:
			t.visible = false

	for f in hidden_fish:
		f.visible = GameState2.fish_revealed

func check_credits() -> void:
	if credits_started:
		return

	var check1: bool = GameState2.fish_revealed
	var check2: bool = GameState2.filter_machine_completed
	var check3: bool = GameState2.trash_cleaned

	if check1 and check2 and check3:
		credits_started = true
		await get_tree().create_timer(5.0).timeout
		%AnimationPlayer.play("Credits")

func _unhandled_input(event):
	# Credits oynarken asansöre dönülemesin
	if credits_started:
		return
	if event.is_action_pressed("interaction") and GameState2.elevator_return_enabled:
		GameState2.last_floor = "kat_5"
		get_tree().change_scene_to_file(ELEVATOR_SCENE)
