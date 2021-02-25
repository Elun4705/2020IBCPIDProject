extends KinematicBody2D

const FaintEffect = preload("res://Effects/FaintEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDEER_TARGET_RANGE = 4


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
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				# An array here will be used to randomly pick a state
				update_wander()

		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_torwards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDEER_TARGET_RANGE:
				update_wander()

		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_torwards_point(player.global_position, delta)
			else:
				state = IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

# An array here will be used to randomly pick a state
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

# Take the XY of Player - XY of Bat - normalized makes the distance 
# one so that it can be muliplied by the speed and acceleration
func accelerate_torwards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	# sprite.flip_h flips the bat sprite so it faces the player/rightside
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtBox.create_hit_effect()
	hurtBox.start_invincibilty(0.4)

func _on_Stats_no_health():
	queue_free()
	var faintEffect = FaintEffect.instance()
	get_parent().add_child(faintEffect)
	faintEffect.global_position = global_position

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")
