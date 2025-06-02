extends CharacterBody2D

#editable

@export var health : float
@export var move_speed : float

#states
var isMoving : bool = false
var isStunned : bool = false

#backend
@onready var playerRef = $"../../Character"
var playerPos : Vector2


func _ready() -> void:
	setupStats()

func setupStats() -> void:
	health = 100
	move_speed = 100

func _physics_process(delta: float) -> void:
	playerPos = playerRef.get_position()
	setMovePosition(playerPos)
	handleMovement(delta)

func handleMovement(delta):
	if $NavigationAgent2D.is_navigation_finished() == false:
		var nextPathPos = $NavigationAgent2D.get_next_path_position()
		velocity = position.direction_to(nextPathPos) * move_speed * delta
		#$NavigationAgent2D.set_velocity(velocity)
		move_and_collide(velocity, false, 0.08, false)
		return
	isMoving = false

func setMovePosition(pos) -> void:
	isMoving = true
	$NavigationAgent2D.set_target_position(pos)

func applyDamage(damage) -> void:
	print("damage applied")
	health -= damage
	spawnDamageParticles()
	if health < 0:
		die()

func spawnDamageParticles():
	var particleScene = Globals.damageParticleScene.instantiate()
	get_parent().add_child(particleScene)
	particleScene.position = self.position

func die() -> void:
	print(str(self) + " died.")
	queue_free()
