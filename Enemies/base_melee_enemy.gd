extends "res://Enemies/base_enemy.gd"

func _ready() -> void:
	super()

#constructor 
func setupStats() -> void:
	max_health = 40
	move_speed = 120
	attack_damage = 15
	knockbackDistance = 400
	isRanged = false

func _process(_delta):
	setMovePosition(playerPos)

#handles logic for moving around
func _physics_process(delta: float) -> void:
	super(delta)

#canattack = false
func attack():
	super()
	$AnimationPlayer.play("Slash")
	$AttackTimer.set_wait_time(1.0/attack_speed)
	$AttackTimer.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		playerInDamageArea = true
		if canAttack:
			attack()
			await get_tree().create_timer(0.25).timeout
			if playerInDamageArea:
				body.applyDamage(attack_damage)
				spawnDamageParticles(body.position)
				body.velocity -= (position - body.position).normalized() * knockbackDistance

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group('Player'):
		playerInDamageArea = false
