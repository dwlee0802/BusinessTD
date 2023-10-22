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

static var repairCost: int = 3

var upkeepHolder: float = 0

const piercingShotRange = 100

var isSupplied: bool = false
var networkUpdateHolder: float = 1

var bodySprite
var connectionRange
var connectionArea
var supplyRange
var supplyArea

var buildTime: float = 7
var	buildTimeLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	bodySprite = get_node("TurretBarrelSprite")
	buildTimeLabel = get_node("BuildTime")
	
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
		maxHitPoints = 1500
		hitPoints = maxHitPoints
		healthBarSize = 200
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	
	if hitPoints < maxHitPoints:
		hitPoints += 5 * delta
		game.operationFunds -= delta * repairCost * 5
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	if upkeepHolder > 1:
		game.operationFunds -= upkeep[type] + fireRateMode - 1
		upkeepHolder = 0
	
	upkeepHolder += delta
		
	
	
func _physics_process(delta):
	if buildTime > 0:
		return
		
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
				currentTarget.ReceiveHit(randi_range(50, 150))
			elif ammoType == 1:
				var hitstuff = get_node("TurretBarrelSprite/APShapeCast").GetColliders()
				for item in hitstuff:
					if item != null:
						item.ReceiveHit(randi_range(50, 150))
						
			fireRateHolder = 0


func hit(damage):
	print("hit!")
	hitPoints -= damage
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
			
	
func _to_string():
	var output = ""
	if isHQ:
		output += "HQ at "
	else:
		output += "Turret at "
	
	output += str(placedTile)
	
	return output
