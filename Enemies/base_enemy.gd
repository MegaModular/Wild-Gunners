extends CharacterBody2D

#editable
var max_health : float
var move_speed : float
var attack_speed = 1
var attack_damage = 10
var knockbackDistance : float

#states
var isMoving : bool = false
var isStunned : bool = false
var isRanged : bool = false
var playerInDamageArea : bool = false

#backend
@onready var playerRef = $"../../Character"
var playerPos : Vector2
var canAttack : bool = true
var health : float

func _ready() -> void:
	Globals.currentEnemyCount += 1
	setupStats()
	health = max_health

func globalBuffs():
	for x in Globals.currentNerfs:
		if x == "strongSpawn":
			attack_damage *= 1.5
			health *= 2
			attack_speed *= 0.75
		if x == "speedyBois":
			if not isRanged:
				move_speed *= 2

#This gets overridden
func setupStats() -> void:
	max_health = 100
	move_speed = 100
	attack_speed = 1
	attack_damage = 10

func _physics_process(delta: float) -> void:
	playerPos = playerRef.get_global_position()
	
	if !isMoving:
		$RotationHelper.look_at(playerPos)
	else:
		$RotationHelper.look_at($NavigationAgent2D.get_next_path_position())
	
	handleHealthBar(delta)
	handleMovement(delta)

func handleHealthBar(delta):
	$Control/Healthbar.max_value = max_health
	$Control/Healthbar.value = lerp($Control/Healthbar.value, health, 10*delta)

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
	Globals.currentEnemyCount -= 1
	for x in Globals.currentBuffs:
		if x == "scorchedEarth":
			var met = Globals.meteorScene.instantiate()
			met.global_position = global_position
			$"../Projectiles".add_child(met)
	queue_free()

func _on_stun_timer_timeout() -> void:
	isStunned = false

func _on_timer_timeout() -> void:
	canAttack = true
