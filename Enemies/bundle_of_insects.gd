extends "res://Enemies/base_ranged_enemy.gd"

func setupStats() -> void:
	max_health = 5
	move_speed = 200
	isRanged = true
	attack_damage = 10
	attack_speed = 0.35
	attack_speed *= randf_range(0.85, 1.15)
	knockbackDistance = 200
	projSpeed = 400
	maxRange = 800
	randomize()

func die():
	for i in range(randi_range(6, 8)):
		var fly = Globals.flyScene.instantiate()
		fly.global_position = self.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		get_parent().add_child(fly)
	super()
