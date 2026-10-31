extends CharacterBody2D

@onready var interaction_area = $InteractionArea

var current_item: Area2D = null # Şu an taşınan eşya
var SPEED = 500
#const JUMP_POWER = -1000

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
	
	if velocity.length() > 0:
		%"İlke".play_running_animation()
	else:
		%"İlke".play_idle_animation()
	
	move_and_slide()
	

func _input(event):
	# "E" tuşuna veya tanımladığınız etkileşim tuşuna basıldığında
	if event.is_action_pressed("interaction"): # 'ui_accept' genelde Enter/Space'dir, Input Map'ten değiştirebilirsiniz
		if current_item == null:
			try_pick_up_item()


func try_pick_up_item():
	# Karakterin etkileşim alanındaki alanları kontrol et
	var overlapping_areas = interaction_area.get_overlapping_areas()
	
	for area in overlapping_areas:
		# Eğer alan bir "Item" ise ve henüz alınmadıysa
		if area.has_method("pick_up") and not area.is_picked_up:
			current_item = area
			current_item.pick_up(self)
			break # Tek seferde sadece bir item al
