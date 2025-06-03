extends Area2D

var direction : Vector2

var isPlayerOwned : bool
var projectileSpeed : float
var projectileDamage : float
var projectileKnockback : float

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = direction.normalized() * projectileSpeed * delta
	position += velocity 

func _on_body_entered(body: Node2D) -> void:
	if isPlayerOwned:
		pass
	if body.is_in_group("Player"):
		body.applyDamage(projectileDamage)
		var particles = Globals.damageParticleScene.instantiate()
		get_parent().add_child(particles)
		particles.position = body.position
		body.velocity -= (position - body.position).normalized() * projectileKnockback
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
