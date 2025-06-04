extends "res://Enemies/base_ranged_enemy.gd"

func setupStats() -> void:
	max_health = 15
	move_speed = 100
	isRanged = true
	attack_damage = 20
	attack_speed = 0.2
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 1000
	projSpeed = 1000
	maxRange = 800
	randomize()
