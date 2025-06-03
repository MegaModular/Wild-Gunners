extends CharacterBody2D

#editable

@export var health : float
@export var move_speed : float
@export var attack_speed = 1
@export var attack_damage = 10
@export var knockbackDistance : float

#states
var isMoving : bool = false
var isStunned : bool = false
var isRanged : bool = false
var playerInDamageArea : bool = false

#backend
@onready var playerRef = $"../../Character"
var playerPos : Vector2
var canAttack : bool = true

func _ready() -> void:
	setupStats()

func setupStats() -> void:
	health = 100
	move_speed = 100
	attack_speed = 1
	attack_damage = 10

func _physics_process(delta: float) -> void:
	playerPos = playerRef.get_position()
	
	if !isMoving:
		$RotationHelper.look_at(playerPos)
	else:
		$RotationHelper.look_at($NavigationAgent2D.get_next_path_position())
	
	handleMovement(delta)

func handleMovement(delta):
	#disable movement if stunned
	if isStunned:
		velocity = lerp(velocity, Vector2.ZERO, 0.1)
		move_and_collide(velocity, false, 0.08, false)
		return
	#disable movement if not moving
	if !isMoving:
		return
	
	#normal moving
	if $NavigationAgent2D.is_navigation_finished() == false && !isStunned:
		var nextPathPos = $NavigationAgent2D.get_next_path_position()
		velocity = position.direction_to(nextPathPos) * move_speed * delta
		#$NavigationAgent2D.set_velocity(velocity)
		move_and_collide(velocity, false, 0.08, false)
		return
	isMoving = false

#overridden function
func attack():
	canAttack = false

#overridden function
func setMovePosition(pos) -> void:
	isMoving = true
	$NavigationAgent2D.set_target_position(pos)

#overridden function
func stopMoving() -> void:
	isMoving = false
	$NavigationAgent2D.set_target_position(position)

func applyDamage(damage) -> void:
	print("damage applied")
	health -= damage
	spawnDamageParticles(position)
	if health < 0:
		die()

func spawnDamageParticles(pos):
	var particleScene = Globals.damageParticleScene.instantiate()
	get_parent().add_child(particleScene)
	particleScene.position = pos

func bashAway(playerPos, strength):
	var diffPos = (position - playerPos).normalized()
	velocity += diffPos * strength
	stun(1.5)

func stun(time):
	isStunned = true
	$StunTimer.set_wait_time(time)
	$StunTimer.start()

func die() -> void:
	print(str(self) + " died.")
	queue_free()

func _on_stun_timer_timeout() -> void:
	isStunned = false

func _on_timer_timeout() -> void:
	canAttack = true
