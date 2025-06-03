extends "res://Enemies/base_enemy.gd"

@onready var raycast = $RayCast2D

var distToPlayer : float = 999999
var maxRange
var projSpeed
var isSmart : bool

func _ready() -> void:
	super()

func setupStats() -> void:
	health = 100
	move_speed = 100
	isRanged = true
	attack_damage = 10
	attack_speed = 0.35
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 200
	projSpeed = 400
	maxRange = 800
	randomize()

func _process(delta: float) -> void:
	doLogicShit()

func doLogicShit():
	raycast.target_position = playerPos - position
	distToPlayer = position.distance_to(playerPos)
	
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Player"):
		if distToPlayer < maxRange:
			if canAttack:
				attack()
			stopMoving()
			return
		else:
			setMovePosition(playerPos)

func attack():
	super()
	if randi_range(0, 1) % 2 == 0:
		isSmart = true
	else:
		isSmart = false
	
	
	var proj = Globals.projectileScene.instantiate()
	$"../../Projectiles".add_child(proj)
	proj.isPlayerOwned = false
	proj.projectileDamage = attack_damage
	proj.projectileKnockback = knockbackDistance
	#Where player is
	if isSmart == true:
		proj.look_at(playerPos - position)
		proj.direction = playerPos - position
		proj.position = position
		proj.projectileSpeed = projSpeed

	#Where player will be
	else:
		var desiredPos = calcAimHacks(position, playerPos, playerRef.velocity, projSpeed)
		proj.look_at(desiredPos)
		proj.direction = desiredPos
		proj.position = position
		proj.projectileSpeed = projSpeed
	
	$AttackTimer.set_wait_time(1.0/attack_speed)
	$AttackTimer.start()

func calcAimHacks(pos: Vector2, target: Vector2, target_velocity: Vector2,  projectile_speed: float) -> Vector2:
	#projectile_speed *= randf_range(0.9, 1.1)
	
	var to_target = target - pos
	var a = target_velocity.length_squared() - projectile_speed * projectile_speed
	var b = 2 * to_target.dot(target_velocity)
	var c = to_target.length_squared()
	
	var discriminant = b * b - 4 * a * c
	
	if discriminant < 0 or abs(a) < 0.001:
		return to_target.normalized()
	var sqrt_disc = sqrt(discriminant)
	var t1 = (-b + sqrt_disc) / (2 * a)
	var t2 = (-b - sqrt_disc) / (2 * a)
	var t = min(t1, t2)
	if t < 0:
		t = max(t1, t2)
	if t < 0:
		return to_target.normalized()
	var future_target_position = target + target_velocity * t
	return (future_target_position - pos).normalized()

func _physics_process(delta: float) -> void:
	super(delta)
