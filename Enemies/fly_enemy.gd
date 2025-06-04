extends "res://Enemies/retreating_enemy.gd"

func setupStats() -> void:
	max_health = 5
	move_speed = 300
	isRanged = true
	attack_damage = 2
	attack_speed = 0.5
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 20
	projSpeed = 800
	maxRange = 350
	randomize()

var closerBias = 1

func attack():
	print("attack called")
	
	minRange *= closerBias
	minRange = randf_range(50, 500)
	maxRange = minRange + 100
	super()
