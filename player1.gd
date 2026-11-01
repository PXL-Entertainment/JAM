extends CharacterBody2D

@onready var pickup_area: Area2D = $PickupArea
@onready var hold_point: Marker2D = $HoldPoint

var held_item: Node2D = null

var SPEED = 500
#const JUMP_POWER = -1000

func _ready() -> void:
	# Onceki sahneden elimde bir esya tasiniyorsa, onu burada tekrar ele al.
	if GameState.held_item_copy != null:
		held_item = GameState.held_item_copy
		GameState.held_item_copy = null
		hold_point.add_child(held_item)
		held_item.position = Vector2.ZERO
		held_item.rotation = 0
		_set_item_held(held_item, true)

func _exit_tree() -> void:
	# Sahne degismeden hemen once, elimdeki esyanin bir kopyasini
	# GameState'e birakiyorum ki yeni sahnede tekrar elime gelsin.
	if held_item != null and is_instance_valid(held_item):
		var copy := held_item.duplicate()
		if held_item.has_meta("item_key"):
			copy.set_meta("item_key", held_item.get_meta("item_key"))
		copy.set_meta("carried_instance", true)
		GameState.held_item_copy = copy
	else:
		GameState.held_item_copy = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_POWER
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		%"İlke".flip_h = direction < 0 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if abs(velocity.x) > 0:
		%"İlke".play_running_animation()
	else:
		%"İlke".play_idle_animation()
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction"):      # E
		var machine := get_nearby_machine()
		var target := get_nearby_interactable()

		if held_item != null and machine != null and machine.can_accept(held_item):
			machine.accept_item(held_item)
			held_item = null
		elif held_item == null and target != null and target.can_interact():
			target.interact()
		elif held_item == null:
			pick_up_nearest()

	elif event.is_action_pressed("drop"):        # F
		if held_item != null:
			drop_item()


func pick_up_nearest() -> void:
	var nearest: Node2D = null
	var nearest_dist := INF

	# Hem Area2D hem RigidBody2D item'lari tara
	var candidates: Array = []
	candidates.append_array(pickup_area.get_overlapping_areas())
	candidates.append_array(pickup_area.get_overlapping_bodies())

	for c in candidates:
		if c.is_in_group("items"):
			var d := global_position.distance_to(c.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = c

	if nearest:
		held_item = nearest
		_set_item_held(held_item, true)
		held_item.get_parent().remove_child(held_item)
		hold_point.add_child(held_item)
		held_item.position = Vector2.ZERO
		held_item.rotation = 0


func drop_item() -> void:
	var world := get_parent()
	var drop_pos := global_position + Vector2(0, -10)

	hold_point.remove_child(held_item)
	world.add_child(held_item)
	held_item.global_position = drop_pos
	_set_item_held(held_item, false)
	held_item = null


func _set_item_held(item: Node, held: bool) -> void:
	if item.has_method("set_held"):
		item.set_held(held)                         # RigidBody2D item
	else:
		item.set_deferred("monitorable", not held)  # Area2D item


func get_nearby_interactable() -> Area2D:
	var nearest: Area2D = null
	var nearest_dist := INF

	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("interactables"):
			var d := global_position.distance_to(area.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = area

	return nearest


func get_nearby_machine() -> Area2D:
	var nearest: Area2D = null
	var nearest_dist := INF

	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("machines"):
			var d := global_position.distance_to(area.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = area

	return nearest
