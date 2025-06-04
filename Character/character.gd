extends CharacterBody2D

#Editable

var attackSpeed = 1 # one attack is 0.7 seconds, this is a multiplier

var max_health : float = 200.0
var damage : float = 10.1

var move_speed = 40
var rotation_speed = 5.0

var maxShieldHealth = 100.0
var shieldRegenRate = 10.0 #per second
var shieldBashDamage = 20.0
var shieldBashStrength = 20
var shieldKickBackDistance = 800
var shieldDurabilityDamage = 40.0
var shieldProjectileDurabilityDamage = 10.0

var dashDistance = 200

#States`
var ableToAttack : bool = true
var isDefending : bool = false
var shieldUp : bool = false
var canShieldBash : bool = false

#backend
var shieldHealth : float = 0

var currentFocus = Vector2.ZERO
var direction = Vector2.ZERO
var raisingShield : float = 0
var health : float

var enemiesInAttackArea = []

func _ready() -> void:
	$UI/HPBar.value = max_health
	$UI/ProgressBar.value = maxShieldHealth
	calcStats()

func calcStats() -> void:
	health = max_health
	$UI/HPBar.max_value = health
	$UI/ProgressBar.max_value = maxShieldHealth

func _process(delta: float) -> void:
	debugFunc()
	
	calculateMovement(delta)
	pointStuffAtCursor(delta)
	shieldLogic(delta)
	updateStatBars(delta)
	
	if Input.is_action_just_pressed("lmb"):
		attack()
	
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

@onready var fill_stylebox := $UI/HPBar.get_theme_stylebox("fill", "ProgressBar") as StyleBoxFlat

func updateStatBars(delta) -> void:
	$UI/ProgressBar.value = lerp($UI/ProgressBar.value, shieldHealth, 5*delta)
	$UI/HPBar.value = lerp($UI/HPBar.value, health, 5*delta)
	var ratio := clampf($UI/HPBar.value / $UI/HPBar.max_value, 0.0, 1.0)
	var new_color := Color(1.0, 0, 0, 0.4).lerp(Color(0.0, 1.0, 0.0, 0.4), ratio)
	fill_stylebox.bg_color = new_color
	

func pointStuffAtCursor(delta) -> void:
	var mouse_pos = get_global_mouse_position()
	var to_mouse = (mouse_pos - global_position).normalized()
	var current_rotation = $CursorHolder.rotation
	var target_rotation = to_mouse.angle()
	$CursorHolder.rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)

#Handles player movement
func calculateMovement(_delta) -> void:
	direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		direction += Vector2(0, 1)
	if Input.is_action_pressed("left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		direction += Vector2(1, 0)
	
	velocity += (direction.normalized() * move_speed)
	move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, 0.125)

func attack() -> void:
	if ableToAttack && !isDefending:
		$AnimationPlayer.set_speed_scale(attackSpeed)
		$AnimationPlayer.play('slash')
		$SlashCooldown.set_wait_time(0.7 * (1.0/attackSpeed))
		$SlashCooldown.start()
		velocity += (get_global_mouse_position() - position).normalized() * dashDistance
		ableToAttack = false
		await get_tree().create_timer(0.2 * 1.0/attackSpeed).timeout
		$CursorHolder/AttackArea/CollisionShape2D2.disabled = false
		await get_tree().create_timer(0.2 * 1.0/attackSpeed).timeout
		$CursorHolder/AttackArea/CollisionShape2D2.disabled = true

func shieldLogic(delta) -> void:
	#shield regen
	if !isDefending:
		if shieldHealth < maxShieldHealth:
			shieldHealth += shieldRegenRate * delta
	clamp(shieldHealth, 0, maxShieldHealth)
	
	#raising shield up
	if ableToAttack && Input.is_action_pressed("rmb") && shieldHealth > 20:
		isDefending = true
		raisingShield = lerp(raisingShield, 1.0, 4 *delta)
	#lowering shield
	else:
		raisingShield = lerp(raisingShield, 0.0, 4*delta)
		shieldUp = false
		$CursorHolder/DefendArea/CollisionShape2D.disabled = true
		if raisingShield < 0.025 && isDefending:
			isDefending = false
	#Shield is up
	if raisingShield > 0.87 && shieldHealth > 0:
		shieldUp = true
		$CursorHolder/DefendArea/CollisionShape2D.disabled = false
	
	if(raisingShield < 0.87):
		$CursorHolder/Shield.visible = false
	else: 
		$CursorHolder/Shield.visible = true

func applyDamage(damage) -> void:
	print("player hurt" + str(damage))
	health -= damage

func _on_slash_cooldown_timeout() -> void:
	ableToAttack = true
	canShieldBash = true

func debugFunc():
	$Control/debuglable.text = "hi"
	$Control/debuglable2.text = str(shieldHealth)
	$Control/debuglable3.text = str(raisingShield)

func _attackAreaDetected(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.applyDamage(damage)

func _on_defend_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.bashAway(self.position, shieldBashStrength)
		body.applyDamage(shieldBashDamage)
		velocity += (position - body.position).normalized() * shieldKickBackDistance
		if shieldHealth - body.attack_damage > 0:
			shieldHealth -= body.attack_damage
		else:
			shieldHealth = 0
		
		var particles = Globals.shieldBashParticleScene.instantiate()
		$"../EnemiesHolder".add_child(particles)
		particles.position = position
		particles.rotation = get_angle_to(get_global_mouse_position() - position)

func _on_defend_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.isPlayerOwned == false:
			area.queue_free()
			if shieldHealth - area.projectileDamage > 0:
				shieldHealth -= area.projectileDamage
			else:
				shieldHealth = 0
