extends Area2D

@export var item_name: String = "Kılıç"
var is_picked_up: bool = false
var target_character: CharacterBody2D = null

func _process(delta):
	# Eğer eşya yerden alındıysa, karakterin üzerindeki belirteç noktasını takip et
	if is_picked_up and target_character:
		# Karakterin üzerinde tanımlayacağımız "HoldMarker" pozisyonuna yumuşak geçiş yap
		var hold_pos = target_character.get_node("HoldMarker").global_position
		global_position = global_position.lerp(hold_pos, 20 * delta)

func pick_up(character: CharacterBody2D):
	is_picked_up = true
	target_character = character
	
	# Eşya alındığı için yerdeki çarpışma alanını kapatıyoruz
	$CollisionShape2D.disabled = true
