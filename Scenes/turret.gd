extends CharacterBody2D

var hitPoints: int = 500
var maxHitPoints: int = 500

# 0: turret, 1: HQ, 2: Drill
var type: int = 0

var ammoType: int = 0
var ammoTypeFireRate = [1, 0.9, 1, 1]

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
var upkeepLow = [3, 5, 2]
var upkeepHigh = [3, 5, 2]

var upkeepHolder: float = 0

const piercingShotRange = 100

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
		
		if game.selectedUnit == self:
			game.selectedUnit = null
			
		queue_free()
		
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	if upkeepHolder > 1:
		game.operationFunds -= upkeep[type] + fireRateMode - 1
		upkeepHolder = 0
	
	upkeepHolder += delta
		
	
	
func _physics_process(delta):
	fireRateHolder += delta
	if fireRateHolder > fireRate * fireRateModifier * ammoTypeFireRate[ammoType]:
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
			if ammoType == 0:
				currentTarget.ReceiveHit(randi_range(20, 40))
			elif ammoType == 1:
				var hitstuff = get_node("TurretBarrelSprite/APShapeCast").GetColliders()
				for item in hitstuff:
					if item != null:
						item.ReceiveHit(randi_range(20, 40))
				
				print(len(hitstuff))
						
			fireRateHolder = 0


func hit(damage):
	print("hit!")
#	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)
	
	
func ChangeFireRate(ammotype):
	fireRateMode = ammotype
	
	# low
	if fireRateMode == 0:
		fireRateModifier = 1.5
	# base
	if fireRateMode == 1:
		fireRateModifier = 1
	# high
	if fireRateMode == 2:
		fireRateModifier = 0.5
		
	print("changed fire rate to ", ammotype)
		
		
func ChangeAmmoType(ammotype):
	ammoType = ammotype
	
	get_node("TurretBarrelSprite/APAreaSprite").visible = false
	
	# regular
	if ammoType == 0:
		print("changed ammo to regular")
	# AP
	if ammoType == 1:
		print("changed ammo to AP")
		get_node("TurretBarrelSprite/APAreaSprite").visible = true
	# Incendiary
	if ammoType == 2:
		print("changed ammo to Incendiary")
	# Incendiary AP
	if ammoType == 2:
		print("changed ammo to Incendiary AP")
	
	
func _to_string():
	var output = ""
	if isHQ:
		output += "HQ at "
	else:
		output += "Turret at "
	
	output += str(placedTile)
	
	return output
