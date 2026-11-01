extends Node

var ocean_color_changed := false
var trash_cleaned := false
var fish_revealed := false
var turtle_blockers_cleared: int = 0
var turtle_bottle_taken: bool = false

var ocean_color := Color(0x00a0ffff)

signal elevator_return_changed(enabled: bool)

var elevator_return_enabled := true:
	set(value):
		elevator_return_enabled = value
		elevator_return_changed.emit(value)

var last_floor := ""
