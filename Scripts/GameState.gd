extends Node
## AUTOLOAD: Project > Project Settings > Autoload, Node Name: GameState

# Sahne degisirken elde tasinan esyanin kopyasi buraya geciciyor olarak konur.
var held_item_copy: Node2D = null

# key -> {"scene_path": String, "position": Vector2, "held": bool}
var _item_locations: Dictionary = {}

# scene_path -> Array[Node]  (baska bir odadan "park edilmis", bu sahne
# acilinca otomatik geri konacak esyalar)
var _parked_items: Dictionary = {}

var _last_scene_path: String = ""

# key -> {"current_count": int, "completed": bool, "given_items": Array}
var _machine_states: Dictionary = {}

func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	if scene.scene_file_path != _last_scene_path:
		_last_scene_path = scene.scene_file_path
		_on_scene_entered(scene)


func _on_scene_entered(scene: Node) -> void:
	var path := scene.scene_file_path
	if not _parked_items.has(path):
		return
	var items: Array = _parked_items[path]
	_parked_items.erase(path)
	for item in items:
		if not is_instance_valid(item):
			continue
		scene.add_child(item)
		var key: String = item.get_meta("item_key", "")
		var loc = get_item_location(key)
		if loc != null:
			item.global_position = loc.get("position", item.global_position)


func get_item_location(key: String):
	return _item_locations.get(key, null)


func set_item_location(key: String, scene_path: String, pos: Vector2) -> void:
	_item_locations[key] = {"scene_path": scene_path, "position": pos, "held": false}


func mark_item_held(key: String) -> void:
	if _item_locations.has(key):
		_item_locations[key]["held"] = true
	else:
		_item_locations[key] = {"scene_path": "", "position": Vector2.ZERO, "held": true}


## Bir odadan ayrilmadan hemen once cagrilir (scene_fader.gd icinden).
## O odada serbest duran (elde olmayan) tum esyalari "park" eder, boylece
## sahne kapanirken yok olmazlar; hangi odaya giderseniz gidin, bu odaya
## geri donunce otomatik olarak eski yerlerinde belirirler.
func park_loose_items(current_scene: Node) -> void:
	for item in get_tree().get_nodes_in_group("items"):
		if not is_instance_valid(item):
			continue
		if _is_under_hold_point(item):
			continue
		var key: String = item.get_meta("item_key", "")
		if key == "":
			continue
		var parent := item.get_parent()
		if parent == null:
			continue
		parent.remove_child(item)
		if not _parked_items.has(current_scene.scene_file_path):
			_parked_items[current_scene.scene_file_path] = []
		_parked_items[current_scene.scene_file_path].append(item)
		set_item_location(key, current_scene.scene_file_path, item.global_position)


func _is_under_hold_point(node: Node) -> bool:
	var p := node.get_parent()
	while p != null:
		if p.name == "HoldPoint":
			return true
		p = p.get_parent()
	return false

func get_machine_state(key: String):
	return _machine_states.get(key, null)


func save_machine_state(key: String, current_count: int, completed: bool, given_items: Array = []) -> void:
	_machine_states[key] = {
		"current_count": current_count,
		"completed": completed,
		"given_items": given_items.duplicate(),
	}
