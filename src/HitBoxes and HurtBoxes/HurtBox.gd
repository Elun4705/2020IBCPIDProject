extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

# Set invincible to true, which starts the timer. 
# Once done sets back to false - Creates new signals 
# Duration is theset amount of time for the invincivility
func start_invincibilty(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	# Instead of calling the parent like before, I switched the code
	# so as to be less confusing
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position


func _on_Timer_timeout():
	self.invincible = false

# Checks for which collision to look out for (repeatedly)

func _on_HurtBox_invincibility_ended():
	monitorable = true

func _on_HurtBox_invincibility_started():
	set_deferred("monitorable", false)
