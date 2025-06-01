extends CharacterBody2D

#Editable
var move_speed = 40
var rotation_speed = 5.0

var maxShieldHealth = 100.0
var shieldRegenRate = 10.0 #per second

var dashDistance = 600

#States`
var ableToAttack : bool = true
var isDefending : bool = false
var shieldUp : bool = false

#backend
var shieldHealth : float = 0

var currentFocus = Vector2.ZERO
var direction = Vector2.ZERO
var raisingShield :float = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	debugFunc()
	
	calculateMovement(delta)
	pointStuffAtCursor(delta)
	shieldLogic(delta)
	
	if Input.is_action_just_pressed("lmb"):
		attack()
	
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

func pointStuffAtCursor(delta) -> void:
	var mouse_pos = get_global_mouse_position()
	var to_mouse = (mouse_pos - global_position).normalized()
	var current_rotation = $CursorHolder.rotation
	var target_rotation = to_mouse.angle()
	$CursorHolder.rotation = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)

#Handles player movement
func calculateMovement(delta) -> void:
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
		$AnimationPlayer.play('slash')
		$SlashCooldown.start()
		velocity += (get_global_mouse_position() - position).normalized() * dashDistance
		ableToAttack = false

func shieldLogic(delta) -> void:
	#shield regen
	if !isDefending:
		if shieldHealth < maxShieldHealth:
			shieldHealth += shieldRegenRate * delta
	clamp(shieldHealth, 0, maxShieldHealth)
	
	#raising shield up
	if ableToAttack && Input.is_action_pressed("rmb"):
		isDefending = true
		raisingShield = lerp(raisingShield, 1.0, 4 *delta)
	#lowering shield
	else:
		raisingShield = lerp(raisingShield, 0.0, 4*delta)
		shieldUp = false
		if raisingShield < 0.1 && isDefending:
			isDefending = false
	#Shield is up
	if raisingShield > 0.87:
		shieldUp = true
		$CursorHolder/DefendArea/CollisionShape2D.disabled = false
	
	if(raisingShield < 0.87):
		$CursorHolder/Shield.modulate = Color(255, 255, 255, 0)
	else: 
		$CursorHolder/Shield.modulate = Color(255, 255, 255, 255)

func _on_slash_cooldown_timeout() -> void:
	ableToAttack = true

func debugFunc():
	$debuglable.text = str(maxShieldHealth)
	$debuglable2.text = str(shieldHealth)
	$debuglable3.text = str(isDefending)
