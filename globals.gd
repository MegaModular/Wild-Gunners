extends Node

var globalNerfsList = ["stormEye", "meteors", "doubleSpawn", 'strongSpawn', 'heavyShield', 'speedybois', 'stoneFeet', 'scorchedEarth', 'ratInfestation', 'flyInfestation', 'beeHive'] 

var globalBuffsList = ["regen", "dasher", "veryStrong", "strongShield", "movementGod"]

var currentNerfs = []
var currentBuffs = []

var currentEnemyCount = 0

var roundCount = 0

func handleNewRound():
	roundCount += 1
	currentNerfs.append(globalNerfsList.pick_random())
	currentBuffs.append(globalBuffsList.pick_random())
	print("New Round:" + str(roundCount) + "\nNerfs=")
	print(str(currentNerfs) + "\nBuffs=" + str(currentBuffs))

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
