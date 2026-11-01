extends Node2D

@onready var ocean: Sprite2D = $Ocean
@onready var trash_nodes = [$Trash4]
@onready var hidden_fish = [$Fish3]  # Fish3'ün altındaki çocuklar da gizlenir

func _ready():
	apply_state()

func apply_state():
	if GameState2.ocean_color_changed:
		ocean.modulate = GameState2.ocean_color

	if GameState2.trash_cleaned:
		for t in trash_nodes:
			t.visible = false

	for f in hidden_fish:
		f.visible = GameState2.fish_revealed
