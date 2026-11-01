extends Control

const HOVER_MULT := 1.1   # fare üzerindeyken büyüme oranı
const PRESS_MULT := 0.9   # tıklayınca küçülme oranı
const DURATION := 0.12    # animasyon süresi (saniye)

var base_scales := {}
var tweens := {}

func _ready() -> void:
	for child in get_children():
		if child is BaseButton:
			_setup_button(child)

func _setup_button(b: BaseButton) -> void:
	base_scales[b] = b.scale
	b.pivot_offset = b.size / 2  # butonun merkezinden ölçeklensin
	b.mouse_entered.connect(_animate.bind(b, HOVER_MULT))
	b.mouse_exited.connect(_animate.bind(b, 1.0))
	b.button_down.connect(_animate.bind(b, PRESS_MULT))
	b.button_up.connect(_on_button_up.bind(b))

func _on_button_up(b: BaseButton) -> void:
	# Fare hâlâ butonun üzerindeyse hover boyutuna, değilse normale dön
	_animate(b, HOVER_MULT if b.is_hovered() else 1.0)

func _animate(b: BaseButton, mult: float) -> void:
	if tweens.has(b) and tweens[b]:
		tweens[b].kill()
	var t := create_tween()
	tweens[b] = t
	t.tween_property(b, "scale", base_scales[b] * mult, DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
