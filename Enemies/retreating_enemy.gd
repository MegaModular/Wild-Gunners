extends "res://Enemies/base_ranged_enemy.gd"

var minRange : float = 200

func setupStats() -> void:
	max_health = 15
	move_speed = 220
	isRanged = true
	attack_damage = 3
	attack_speed = 1.4
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 200
	projSpeed = 800
	maxRange = 350
	randomize()

func doLogicShit():
	raycast.target_position = (playerPos - global_position) * 1/scale.x
	distToPlayer = global_position.distance_to(playerPos)
	
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Player"):
		if distToPlayer < maxRange and distToPlayer > minRange:
			if canAttack:
				attack()
			stopMoving()
			return
		else:
			if distToPlayer > maxRange:
				setMovePosition(playerPos)
			else:
				setMovePosition((playerPos - global_position).normalized() * -200 + global_position + Vector2(randf_range(-200, 200), randf_range(-200, 200)))
