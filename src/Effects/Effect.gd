extends AnimatedSprite

func _ready():
	# Self here verifies the sprite that it's checking
	# warning-ignore:return_value_discarded
	connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	frame = 0
	play("Animate")

func _on_AnimatedSprite_animation_finished():
	queue_free()
