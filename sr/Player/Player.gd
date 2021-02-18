extends KinematicBody2D

""" This makes it possible so the number can be changed while debugging """
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

""" Starts 'switch' like operation"""
enum {
	MOVE,
	ROLL,
	ATTACK,
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitBoxPivot/SwordHitBox
onready var hurtbox = $HurtBox

func _ready():
	""" Connects the stats to the rest of the objects inside Player """
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	""" Works as a switch statement, but works as an abstarct class 
	too as the code is being written on another line """
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	""" This is where the animation is placed so that it matches the movement """
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func move():
	velocity = move_and_slide(velocity)

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finished():
	velocity = velocity * 0.8
	state = MOVE
	
func roll_animation_finished():
	state = MOVE

func _on_HurtBox_area_entered(_area):
	stats.health -= 1
	hurtbox.start_invincibilty(0.5)
	hurtbox.create_hit_effect()
