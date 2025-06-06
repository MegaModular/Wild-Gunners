extends Area2D

var dist = randf_range(1000, 2000)
var speed = randf_range(500, 1000)

var bodiesInArea = []

func _ready():
	randomize()
	rotation = randf_range(0, 2*3.14)
	$Node2D.set_position(Vector2(dist, 0))

func _process(delta: float) -> void:
	if $Node2D.position.x < 0:
		$Explosion.emitting = true
		$Node2D/MeteorParticles.emitting = false
		for b in bodiesInArea:
			b.applyDamage(50)
		$CollisionShape2D.disabled = true
	else:
		$Node2D.position.x -= speed * delta

func _on_explosion_finished() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		bodiesInArea.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body in bodiesInArea:
		bodiesInArea.erase(body)
