extends KinematicBody2D

const FaintEffect = preload("res://Effects/FaintEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200


enum {
	IDLE,
	WANDER,
	CHASE,
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtBox = $HurtBox

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				""" Take the XY of Player - XY of Bat - normalized makes the distance 
				one so that it can be muliplied by the speed and acceleration """
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			""" sprite.flip_h flips the bat sprite so it faces the player """
			sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)
			
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
	

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var faintEffect = FaintEffect.instance()
	get_parent().add_child(faintEffect)
	faintEffect.global_position = global_position
