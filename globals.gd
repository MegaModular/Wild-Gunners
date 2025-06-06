extends Node

var globalNerfsList = ["meteors", "doubleSpawn", 'strongSpawn', 'heavyShield', 'speedyBois', 'stoneFeet', 'scorchedEarth', 'ratInfestation', 'flyInfestation', 'beeHive'] 

var globalBuffsList = ["regen", "dasher", "veryStrong", "strongShield", "movementGod"]

var currentNerfs = []
var currentBuffs = []

var currentEnemyCount = 0

var roundCount = 0

func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

func handleNewRound():
	roundCount += 1
	for i in range(1 + floor(roundCount/2)):
		if i % 2 == 0:
			addUniqueModifier(true)
		addUniqueModifier(false)
	print("New Round:" + str(roundCount) + "\nNerfs=")
	print(str(currentNerfs) + "\nBuffs=" + str(currentBuffs))


func addUniqueModifier(isBuff):
	#buffs
	if isBuff:
		var y = globalBuffsList.pick_random()
		if globalBuffsList.size() == currentBuffs.size():
			return
		else:
			while y in currentBuffs:
				y = globalBuffsList.pick_random()
		currentBuffs.append(y)
		return
	#nerfs
	var y = globalNerfsList.pick_random()
	if globalNerfsList.size() == currentNerfs.size():
		return
	else:
		while y in currentNerfs:
			y = globalNerfsList.pick_random()
	currentNerfs.append(y)

func handleEndRound():
	currentBuffs.clear()
	currentNerfs.clear()

@onready var damageParticleScene = preload("res://Particles/damage_particles.tscn")
@onready var shieldBashParticleScene = preload("res://Particles/shieldBashParticles.tscn")
@onready var projectileScene = preload("res://Misc/projectile.tscn")

@onready var ratScene = preload("res://Enemies/swarm_enemy.tscn")
@onready var flyScene = preload("res://Enemies/fly_enemy.tscn")
@onready var crocScene = preload("res://Enemies/base_melee_enemy.tscn")
@onready var hunterScene = preload("res://Enemies/base_ranged_enemy.tscn")
@onready var raccoonScene = preload("res://Enemies/fast_melee_enemy.tscn")
@onready var beeScene = preload("res://Enemies/retreating_enemy.tscn")
@onready var sniperScene = preload("res://Enemies/sniper_enemy.tscn")
@onready var sprinkerScene = preload("res://Enemies/sprinker_enemy.tscn")
@onready var bearScene = preload("res://Enemies/tank_enemy.tscn")
@onready var pileOfRatsScene = preload("res://Enemies/pile_of_rats.tscn")
@onready var bundleOfFliesScene = preload("res://Enemies/bundle_of_insects.tscn")

@onready var meteorScene = preload("res://Misc/meteor.tscn")
