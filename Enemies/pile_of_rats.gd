extends "res://Enemies/base_melee_enemy.gd"

func setupStats() -> void:
	max_health = 100
	move_speed = 50
	attack_damage = 5
	knockbackDistance = 400
	isRanged = false


func die():
	for i in range(randi_range(6, 10)):
		var rat = Globals.ratScene.instantiate()
		rat.global_position = self.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		get_parent().add_child(rat)
	super()
