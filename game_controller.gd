extends Node2D

@onready var playerRef = $"../Character"

@onready var projectileRef = $"../Projectiles"

@onready var enemiesHolderRef = $"../EnemiesHolder"

var maxTimeElapsed : bool = true
var spawningMeteors : bool = false
#most of the variables in this are stored in globals.

func startNewRound():
	Globals.handleEndRound()
	playerRef.removeBuffs()
	Globals.handleNewRound()
	playerRef.calcStats()
	maxTimeElapsed = false
	
	var spawnCount = floor(Globals.roundCount/5) + 3
	for x in Globals.currentNerfs:
		if x == "doubleSpawn":
			spawnCount *= 2
	
	for i in range(spawnCount):
		try_spawn_enemy_away_from_camera()

func _process(delta: float) -> void:
	if Globals.currentEnemyCount < 3 && $MinRoundTimer.is_stopped():
		$MinRoundTimer.start()
	
	for i in Globals.currentNerfs:
		if i == "meteors":
			spawningMeteors = true
		else:
			spawningMeteors = false

func _on_min_round_timer_timeout() -> void:
	startNewRound()

func spawnRandomEnemyBunch(pos):
	var rng = randi_range(0, 10)
	var enemy
	
	var minrat = 6
	var maxrat = 10
	
	for i in Globals.currentNerfs:
		if i == "ratInfestation":
			rng = 0
			minrat *= 1.5
			maxrat *= 1.5
		elif i == "flyInfestation":
			rng = 1
			minrat *= 1.5
			maxrat *= 1.5
		elif i== "beeHive":
			rng = 3
			maxrat *= 1.5
			minrat *= 1.5
	
	#rats
	if rng == 0:
		for i in range(minrat, maxrat):
			enemy = Globals.ratScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng ==1:
		for i in range(minrat, maxrat):
			enemy = Globals.flyScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==2:
		for i in range(1):
			enemy = Globals.bearScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==3:
		for i in range(6, 10):
			enemy = Globals.beeScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==4:
		for i in range(minrat*0.5, maxrat * 0.5):
			enemy = Globals.crocScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==5:
		for i in range(3, 6):
			enemy = Globals.hunterScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==6:
		for i in range(2, 4):
			enemy = Globals.sniperScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==7:
		for i in range(3, 5):
			enemy = Globals.raccoonScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==8:
		for i in range(2,4):
			enemy = Globals.sprinkerScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==9:
		for i in range(2,4):
			enemy = Globals.pileOfRatsScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)
	if rng==10:
		for i in range(2,4):
			enemy = Globals.bundleOfFliesScene.instantiate()
			enemy.global_position = pos + Vector2(randf_range(-50, 50), randf_range(-50, 50))
			enemiesHolderRef.add_child(enemy)

#Chatgpt shit lets see what it can do
func get_camera_bounds(camera: Camera2D) -> Rect2:
	var screen_size = get_viewport_rect().size
	var zoom = camera.zoom
	var cam_pos = camera.global_position
	var half_size = screen_size * 0.5 * zoom
	return Rect2(cam_pos - half_size, screen_size * zoom)

func get_random_position_outside_camera(camera_bounds: Rect2, distance: float) -> Vector2:
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var dir = directions[randi() % directions.size()]
	
	var pos = Vector2()
	match dir:
		Vector2.LEFT:
			pos.x = camera_bounds.position.x - distance
			pos.y = randf_range(camera_bounds.position.y, camera_bounds.position.y + camera_bounds.size.y)
		Vector2.RIGHT:
			pos.x = camera_bounds.position.x + camera_bounds.size.x + distance
			pos.y = randf_range(camera_bounds.position.y, camera_bounds.position.y + camera_bounds.size.y)
		Vector2.UP:
			pos.y = camera_bounds.position.y - distance
			pos.x = randf_range(camera_bounds.position.x, camera_bounds.position.x + camera_bounds.size.x)
		Vector2.DOWN:
			pos.y = camera_bounds.position.y + camera_bounds.size.y + distance
			pos.x = randf_range(camera_bounds.position.x, camera_bounds.position.x + camera_bounds.size.x)

	return pos

func is_water_terrain(tilemap: TileMapLayer, pos: Vector2, water_id: int) -> bool:
	var cell = tilemap.local_to_map(tilemap.to_local(pos))
	var tile_data = tilemap.get_cell_tile_data(cell)
	if tile_data == null:
		return false  # No tile here
	var terrain = tile_data.get_terrain()
	return terrain == water_id

func try_spawn_enemy_away_from_camera():
	var camera = get_viewport().get_camera_2d()
	var tilemap = $"../TileMapLayer"
	var cam_bounds = get_camera_bounds(camera)
	
	for i in range(10):
		var pos = get_random_position_outside_camera(cam_bounds, 1000)
		if not is_water_terrain(tilemap, pos, 2):
			spawnRandomEnemyBunch(pos)
			break

func _on_meteor_timer_timeout() -> void:
	if spawningMeteors:
		spawnMeteor()
		$MeteorTimer.set_wait_time(randf_range(0.5, 1.5))

func spawnMeteor():
	var met = Globals.meteorScene.instantiate()
	met.global_position = playerRef.global_position + Vector2(randf_range(-600, 600), randf_range(-600, 600))
	$"../Projectiles".add_child(met)
