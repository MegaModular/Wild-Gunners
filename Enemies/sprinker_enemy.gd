extends "res://Enemies/base_ranged_enemy.gd"

func setupStats() -> void:
	max_health = 15
	move_speed = 100
	isRanged = true
	attack_damage = 2
	attack_speed = 1
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 100
	projSpeed = 400
	maxRange = 800
	randomize()
	$SprinkerTimer.set_wait_time(randf_range(8, 12))

var canSprinkle : bool = true

func _process(delta):
	super(delta)
	if canSprinkle:
		canSprinkle = false
		attack_speed = 10
		await get_tree().create_timer(2).timeout
		attack_speed = 1

func _on_sprinker_timer_timeout() -> void:
	canSprinkle = true
