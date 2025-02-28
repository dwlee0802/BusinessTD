extends CharacterBody2D

class_name Turret

var hitPoints: int = 500
static var maxHitPoints: int = 500
static var maxHQHitPoints: int = 1500

# 0: turret, 1: HQ, 2: Drill
var type: int = 0

var ammoType: int = 0
static var ammoTypeFireRate = [1, 2, 2, 1, 1]
static var ammoTypeCost = [15, 35, 1, 1, 1]
static var ammoTypeDamageRange = [[25, 75], [10,30], [15, 35]]
static var criticalChance: float = 0

var targets = []

# time in seconds between each shots
static var fireRate: float = 0.25
var fireRateHolder: float = 0
var fireRateModifier: float = 1
var fireRateMode: int = 1

var healthBar
var healthBarSize: int = 75

var game

var isHQ: bool = false

var placedTile

var upkeep = [10, 15, 10]
var upkeepLow = [3, 5, 2]
var upkeepHigh = [3, 5, 2]

static var repairCost: int = 3
var repairHolder: float = 1

var upkeepHolder: float = 0

var isSupplied: bool = false
var networkUpdateHolder: float = 1

var bodySprite
var connectionRange
var connectionArea
var supplyRange
var supplyArea

var attackArea

var buildTime: float = 7
var	buildTimeLabel

var muzzleFlashSprite

var debug_undying: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	bodySprite = get_node("TurretBarrelSprite")
	buildTimeLabel = get_node("BuildTime")
	muzzleFlashSprite = get_node("TurretBarrelSprite/MuzzleFlash")
	attackArea = $AttackArea
	
	if isHQ:
		buildTime = 3
		connectionRange = get_node("ConnectionRange")
		connectionArea = get_node("ConnectionArea")
		supplyRange = get_node("SupplyRange")
		supplyArea = get_node("SupplyArea")
		supplyRange.visible = true
		
	healthBar = get_node("Healthbar")
	game = get_parent()
	
	if isHQ:
		hitPoints = maxHQHitPoints
		healthBarSize = 200
	
	game.game_ended.connect(GameEnded)

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
	
	repairHolder += delta
	if repairHolder > 1:
		if isHQ:
			if hitPoints < maxHQHitPoints:
				hitPoints += 10
				game.operationFunds -= repairCost * 10
			else:
				hitPoints = maxHQHitPoints
			
			repairHolder = 0
		
			healthBar.scale.x = healthBarSize * hitPoints / maxHQHitPoints
		else:
			if hitPoints < maxHitPoints:
				hitPoints += 10
				game.operationFunds -= repairCost * 10
			else:
				hitPoints = maxHitPoints
			
			repairHolder = 0
		
			healthBar.scale.x = healthBarSize * hitPoints / maxHitPoints
	
	if buildTime > 0:
		buildTime -= delta
		bodySprite.modulate = Color.DIM_GRAY
		buildTimeLabel.text = str(snapped(buildTime, 0.001))
		return
	else:
		buildTimeLabel.visible = false
		
	if isHQ and game.waitingForBuildLocation == true and game.buildType == 3:
		connectionRange.visible = true
		supplyRange.visible = false
	elif isHQ:
		connectionRange.visible = false
		supplyRange.visible = true
		
	if not isSupplied and not isHQ:
		bodySprite.modulate = Color.DIM_GRAY
		return
		
	bodySprite.modulate = Color.WHITE
		
	
func _physics_process(delta):
	if buildTime > 0:
		return
		
	muzzleFlashSprite.visible = false
	
	if isHQ:
		networkUpdateHolder += delta
		if networkUpdateHolder > 1:
			UpdateNetwork()
			networkUpdateHolder = 0
		
	if not isSupplied and not isHQ:
		bodySprite.modulate = Color.DIM_GRAY
		return
	
	bodySprite.modulate = Color.WHITE
	
	fireRateHolder += delta
	if fireRateHolder > fireRate * fireRateModifier * ammoTypeFireRate[ammoType]:
		# choose the closest target
		targets = attackArea.get_overlapping_bodies()
		
		if len(targets) == 0:
			return
			
		var currentTarget
		var currentDist = 10000
		
		for i in range(len(targets)):
			if i > 10:
				break
			if targets[i] == null:
				continue
			if targets[i] == self:
				continue
				
			var thisDist
			thisDist = global_position.distance_to(targets[i].global_position)
			if thisDist < currentDist:
				currentTarget = targets[i]
				currentDist = thisDist
				
		
		# turn turret towards target
		if currentTarget != null:
			get_node("TurretBarrelSprite").rotation = global_position.angle_to_point(currentTarget.position)
		
			muzzleFlashSprite.visible = true
			var crit = 1
			if randf() < criticalChance:
				crit = 2
				
			# attack target
			if ammoType == 0:
				if crit == 1:
					currentTarget.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]))
				else:
					currentTarget.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]), true)
									
#				game.operationFunds -= ammoTypeCost[0]
			elif ammoType == 1:
				var hitstuff = get_node("TurretBarrelSprite/APShapeCast").GetColliders()
				var count = 0
				for item in hitstuff:
					if count > game.selectedUpgrades[0]:
						break
					count += 1
					if item != null:
						if crit == 1:
							item.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]))
						else:
							item.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]), true)
			elif ammoType == 2:
				if crit == 1:
					currentTarget.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]), false, true)
				else:
					currentTarget.ReceiveHit(crit * randi_range(ammoTypeDamageRange[ammoType][0], ammoTypeDamageRange[ammoType][1]), true, true)
								
				
#				game.operationFunds -= ammoTypeCost[1]
						
						
			fireRateHolder = 0


func hit(damage):
	if debug_undying == true:
		return
		
	print("hit!")
	hitPoints -= damage
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)
	game.camera.ShakeScreen(10, 7)
	
	
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
		
	Market.UpdateConsumption()
	game.UpdateMarketUI()
	
		
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
	if ammoType == 2:
		print("changed ammo to HE")
	# Incendiary
	if ammoType == 3:
		print("changed ammo to Incendiary")
	# Incendiary AP
	if ammoType == 4:
		print("changed ammo to Incendiary AP")
	
	Market.UpdateConsumption()
	game.UpdateMarketUI()
	
	
func UpdateSupply():
	var results = supplyArea.get_overlapping_bodies()
	for item in results:
		if item != null:
			if item.type == 0 or item.type == 2:
				item.isSupplied = true


func UpdateNetwork():
	if not isHQ:
		return
	
#	print("Network Update\n")
	
	var results = connectionArea.get_overlapping_bodies()
	
	for item in game.playerStructures:
		if item != null:
			if item.type == 3:
				item.isConnected = false
				item.UpdateSupply()
				item.visited = false
				
	# update towers
	for item in results:
		if item != null and item.type == 3:
			if item.visited == false:
				item.isConnected = true
				item.visited = true
				item.UpdateConnection()
	
	for item in game.playerStructures:
		if item != null:
			if item.type != 3:
				item.isSupplied = false
				
	UpdateSupply()
	
	for item in game.playerStructures:
		if item != null:
			if item.type == 3:
				item.UpdateSupply()
			
			
func GameEnded():
	hitPoints = 0

	
func _to_string():
	var output = ""
	if isHQ:
		output += "HQ at "
	else:
		output += "Turret at "
	
	output += str(placedTile)
	
	return output
