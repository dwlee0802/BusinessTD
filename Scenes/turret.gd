extends CharacterBody2D

var hitPoints: int = 500
var maxHitPoints: int = 500

# 0: turret, 1: HQ, 2: Drill
var type: int = 0

var attackMode
var ammoType

var targets = []

# time in seconds between each shots
var fireRate: float = 0.25
var fireRateHolder: float = 0
var fireRateModifier: float = 1
var fireRateMode: int = 1

var healthBar
var healthBarSize: int = 75

var game

var isHQ: bool = false

var placedTile

var upkeep = [3, 5, 2]

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	
	if isHQ:
		maxHitPoints = 1500
		hitPoints = maxHitPoints
		healthBarSize = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		if isHQ:
			print("Game Over!")
			game.GameOver()
			
		var tiles
		
		if isHQ:
			tiles = game.GetSquare(placedTile, 7)
		else:
			tiles = game.GetSquare(placedTile, 3)
			
		for tile in tiles:
			for item in tile:
				item.occupied = false
			
		queue_free()
		
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	if isHQ:
		game.operationFunds += -5 * delta
	else:
		game.operationFunds += -3 * delta
		
	
	
func _physics_process(delta):
	# choose the closest target
	targets = get_node("ShapeCast2D").GetColliders()
	
	if len(targets) == 0:
		return
		
	var currentTarget
	var currentDist = 10000
	
	for i in range(len(targets)):
		if i > 10:
			break
		if targets[i] == null:
			continue
		var thisDist
		thisDist = global_position.distance_to(targets[i].global_position)
		if thisDist < currentDist:
			currentTarget = targets[i]
			currentDist = thisDist
	
	# turn turret towards target
	if currentTarget != null:
		get_node("TurretBarrelSprite").rotation = global_position.angle_to_point(currentTarget.position)
	
		# attack target
		fireRateHolder += delta
		if fireRateHolder > fireRate:
			currentTarget.ReceiveHit(randi_range(20, 40))
			fireRateHolder = 0


func hit(damage):
	print("hit!")
	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.LAVENDER_BLUSH)
	
	
func ChangeFireRate(type):
	fireRateMode = type
	
	# low
	if type == 0:
		fireRateModifier *= 0.75
	# base
	if type == 1:
		fireRateModifier *= 1
	# high
	if type == 2:
		fireRateModifier *= 0.75
		
	print("changed fire rate to ", type)
		
func ChangeAmmoType(type):
	ammoType = type
	
	# regular
	if type == 0:
		print("changed ammo to regular")
	# AP
	if type == 1:
		print("changed ammo to AP")
	# Incendiary
	if type == 2:
		print("changed ammo to Incendiary")
	# Incendiary AP
	if type == 2:
		print("changed ammo to Incendiary AP")
		
	
func _to_string():
	var output = ""
	if isHQ:
		output += "HQ at "
	else:
		output += "Turret at "
	
	output += str(placedTile)
	
	return output
