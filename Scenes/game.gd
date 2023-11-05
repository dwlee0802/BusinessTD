extends Node2D


var turretScene = preload("res://Scenes/turret.tscn")
var hqScene = preload("res://Scenes/HQ.tscn")
var enemyScene = preload("res://Scenes/enemyUnit.tscn")
var damagePopupScene = preload("res://Scenes/damage_popup.tscn")
var miningDrillScene = preload("res://Scenes/mining_drill.tscn")
var networkTowerScene = preload("res://Scenes/network_tower.tscn")

var waitingForBuildLocation: bool = false
var waitingForTowerConnectionTarget: bool = false
var buildType

var mouseOnTile

var selectedTile

var selectedUnit

var mouseInUI: bool = false

var homeBlock
var edgeTiles = []

var playerStructures = []

# how many tiles a building of type index takes up
# 0: turret, 1: HQ, 2: Mining Drill
var buildingSizeN = [3, 7, 5, 3]

# upfront cost of buildings
var buildingCosts = [3000, 0, 6000, 1500]

# the time between each enemy wave
var spawnRate: float = 30
var spawnRateHolder: float = 30
# how many enemies spawn for each wave
var spawnCount: float = 10
# determines the rate in which enemy count increases
var difficultyScale: float = 1.35
# determines the rate enemy health increases
var enemyDifficultyIncrease: int = 1
var enemyMaxCount: int = 500
var enemyCurrentCount: int = 0
var enemyCurrentCountUI

var gameStarted: bool = false
var gamePaused: bool = true

signal game_ended

var operationFunds: float = 10000
var highestValuePoint: float = 10000

var operationTime: float = 0
var operationTimeUI

# takes into account the cash in value of buildings
var totalValue: float = 5000
var totalValueGraph

var selectedUpgrades = []
const UPGRADE_COUNT: int = 16

var camera

var unitMenu

# time between market update
var marketUpdateTime: float = 5
var marketUpdateTimeHolder: float = 0

var marketUI

# Called when the node enters the scene tree for the first time.
func _ready():
	Market.game = self
	homeBlock = get_node("MapBlock")
	camera = get_node("Camera")
	operationTimeUI = get_node("Camera/CanvasLayer/InGameUI/OperationTimeUI")
	get_node("Camera").FocusOnTile(homeBlock.blockTiles[int(homeBlock.boardWidth/2)][int(homeBlock.boardWidth/2)])
	enemyCurrentCountUI = get_node("Camera/CanvasLayer/InGameUI/EnemyCountLabel")
	unitMenu = get_node("Camera/CanvasLayer/InGameUI/UnitMenu")
	totalValueGraph = get_node("Camera/CanvasLayer/InGameUI/TotalValueGraph/Graph2D").add_plot_item("", Color.GREEN, 1.0)
	marketUI = get_node("Camera/CanvasLayer/MarketUI")
	
	# initialize upgrades array
	for i in range(UPGRADE_COUNT):
		selectedUpgrades.append(0)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enemyCurrentCountUI.text = "Enemy count: " + str(enemyCurrentCount)
	
	if gameStarted == true:
		if Market.autoSell == true and Market.crystalPrice >= Market.minSellPrice:
			Market.SellCrystals()
			
		marketUpdateTimeHolder -= delta
		if marketUpdateTimeHolder <= 0:
			marketUpdateTimeHolder = marketUpdateTime
			MarketCycle()
			
	# update operation time and player finance ui
	if not playerStructures.is_empty():
		operationTime += delta
		operationTimeUI.text = str(int(operationTime)) + ":" + str(int(operationTime * 100) % 100)
		var assets = 0
		for item in playerStructures:
			if item != null:
				assets += buildingCosts[item.type] * 0.8 * (item.hitPoints / item.maxHitPoints)
			
		totalValue = operationFunds + assets
		
	if totalValue > highestValuePoint:
		highestValuePoint = totalValue
		
	get_node("Camera/CanvasLayer/InGameUI/MostFundsLabel").text = "Highest Value: " + str(int(highestValuePoint))
	get_node("Camera/CanvasLayer/InGameUI/MoneyLabel").text = "Current Funds: " + str(int(operationFunds))
	get_node("Camera/CanvasLayer/InGameUI/Total Value").text = "Current Value: " + str(int(totalValue))
	
	# spawn enemy wave
	if not playerStructures.is_empty() and gameStarted == true:
		gameStarted = true
		spawnRateHolder += delta
		
		if spawnRateHolder > spawnRate:
			# randomly spawn enemies at the edge of the map
			for i in range(15 + int(spawnCount)):
				var target = playerStructures.pick_random()
				if target != null and target.hitPoints > 0:
					SpawnEnemy(edgeTiles.pick_random(), target.placedTile, enemyDifficultyIncrease * 10)
				else:
					target = playerStructures.pick_random()
					
			spawnCount *= difficultyScale
			if spawnCount > enemyMaxCount:
				spawnCount = enemyMaxCount
				enemyDifficultyIncrease += 1
			spawnRateHolder = 0
	
	# add data point to graph
	if int(operationTime) % 10 == 0:
		totalValueGraph.add_point(Vector2(int(operationTime / 10), totalValue))


func MarketCycle():
	Market.Consumption()
	Market.SupplyGrowth()
	Market.UpdateConsumption()
	Market.UpdatePrices()
	UpdateMarketUI()
	

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and mouseInUI == false:
		# Raytrace at mouse position and get tile
		var space = get_viewport().world_2d.direct_space_state
		var param = PhysicsPointQueryParameters2D.new()
		param.position = get_global_mouse_position()
		param.collision_mask = 5
		var result = space.intersect_point(param)
		
		if len(result) == 1:
			selectedTile = result[0].collider
			print(selectedTile)
			selectedUnit = null
		elif len(result) == 2:
			selectedTile = result[0].collider
			selectedUnit = result[1].collider
			get_node("Camera/CanvasLayer/InGameUI/UnitMenu").ShowUnit(selectedUnit)
		else:
			selectedTile = null
			selectedUnit = null
			print("Nothing Selected!\n")
			
			
		if waitingForBuildLocation:
			if selectedTile == null:
				print("No location selected. Cancelling.\n")
				waitingForBuildLocation = false
			else:
				var tiles = GetSquare(selectedTile, buildingSizeN[buildType])
				if tiles == null:
					print("No space to put turret there!\n")
					waitingForBuildLocation = false
				else:
					# check if any of the tiles are located
					for row in tiles:
						for tile in row:
							if tile.occupied == true:
								print("Space already occupied!\n")
								waitingForBuildLocation = false
								return
					
					# area is available for placing building
					if buildType == 0:
						var newTurret = turretScene.instantiate()
						add_child(newTurret)
						newTurret.position = selectedTile.position
						newTurret.placedTile = selectedTile
						newTurret.type = 0
						
						# modify turret range based on selectedUpgrades
						var shapenode = newTurret.get_node("ShapeCast2D").shape
						shapenode.set_radius(shapenode.get_radius() + 100 * selectedUpgrades[6])
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
						
						print("Spawned Turret at ", selectedTile)
						playerStructures.append(newTurret)
						
						operationFunds -= buildingCosts[buildType]
						
						waitingForBuildLocation = false
						UpdateSupply()
						return
						
					elif buildType == 1:
						var newHQ = hqScene.instantiate()
						newHQ.isHQ = true
						newHQ.type = 1
						add_child(newHQ)
						newHQ.position = selectedTile.position
						newHQ.placedTile = selectedTile
						
						operationFunds -= 2000
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
						
						print("Spawned HQ at ", selectedTile)
						waitingForBuildLocation = false
						
						get_node("Camera/CanvasLayer/InGameUI/BuildMenu/BuildButton/BuildOptionsMenu/HQButton").visible = false
						get_node("Camera/CanvasLayer/InGameUI/BuildMenu/BuildButton/BuildOptionsMenu/TurretButton").visible = true
						get_node("Camera/CanvasLayer/InGameUI/BuildMenu/BuildButton/BuildOptionsMenu/MiningDrillButton").visible = true
						get_node("Camera/CanvasLayer/InGameUI/BuildMenu/BuildButton/BuildOptionsMenu/NetworkTowerButton").visible = true
						
						operationFunds -= buildingCosts[buildType]
						playerStructures.append(newHQ)
						gameStarted = true
						
						for item in edgeTiles:
							item.pathToHQ = homeBlock.pathfinding.get_id_path(item.id, selectedTile.id)
								
						return
					
					elif buildType == 2:
						if selectedTile.isDeposit:
							var newDrill = miningDrillScene.instantiate()
							add_child(newDrill)
							newDrill.position = selectedTile.position
							newDrill.placedTile = selectedTile
							newDrill.type = 2
							
							for row in tiles:
								for tile in row:
									tile.occupied = true
									
							print("Spawned Mining Drill at ", selectedTile)
							
							playerStructures.append(newDrill)
							operationFunds -= buildingCosts[buildType]
							return
						else:
							print("Not a mineral deposit!\n")
						
						waitingForBuildLocation = false
						UpdateSupply()
						
					elif buildType == 3:
						var newTower = networkTowerScene.instantiate()
						add_child(newTower)
						newTower.position = selectedTile.position
						newTower.placedTile = selectedTile
						newTower.type = 3
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
								
						playerStructures.append(newTower)
						operationFunds -= buildingCosts[buildType]
						waitingForBuildLocation = false
						print("Spawned Network Tower at ", selectedTile)
						
						playerStructures[0].UpdateNetwork()
					
					else:
						waitingForBuildLocation = false
						print("ERROR! Wrong building type!")
				
				
# returns a list of tiles in a N x N square centered at center tile
# if not possible, returns null
# needs to have more boundary checks
func GetSquare(center, N):
	var output = []
	var col = center.col - int(N/2)
	var row = center.row - int(N/2)
	var topLeft
	
	if col < 0:
		return null
	if row < 0:
		return null
	
	topLeft = homeBlock.blockTiles[row][col]
	
	for j in range(N):
		var firstTileOfRow = topLeft
		var oneRow = []
		
		for i in range(N):
			oneRow.append(firstTileOfRow)
			firstTileOfRow = firstTileOfRow.rightTile
		
		output.append(oneRow)
		topLeft = topLeft.lowerTile
	
	return output
	

func SpawnEnemy(where, attackWhat, addHealth):
	var newUnit = enemyScene.instantiate()
	newUnit.position = where.position
	newUnit.attackTarget = attackWhat
	newUnit.maxHitPoints = 100 + addHealth
	newUnit.hitPoints = newUnit.maxHitPoints
	newUnit.startingTile = where
	newUnit.targetTile = attackWhat
	add_child(newUnit)
	enemyCurrentCount += 1
	
	
func ReceiveUpgrades(upgradeID):
	print("Upgrade ", upgradeID, " received.\n")
	
	selectedUpgrades[upgradeID] += 1
	
	if upgradeID == 0:
		unitMenu.get_node("AmmoChoiceMenu").get_node("OptionButton").add_item("AP", 1)
	if upgradeID == 1:
		unitMenu.get_node("AmmoChoiceMenu").get_node("OptionButton").add_item("HE", 2)
	if upgradeID == 2:
		unitMenu.get_node("AmmoChoiceMenu").get_node("OptionButton").add_item("Incendiary", 3)
	if upgradeID == 3:
		unitMenu.get_node("AmmoChoiceMenu").get_node("OptionButton").add_item("Shotgun", 4)
	if upgradeID == 4:
		unitMenu.get_node("AmmoChoiceMenu").get_node("OptionButton").add_item("Sharpnel", 5)
	if upgradeID == 5:
		Turret.fireRate *= 0.9
	if upgradeID == 6:
		# increase range of existing turrets
		for item in playerStructures:
			if item != null and item.type == 0 or item.type == 1:
				var shapenode = item.get_node("ShapeCast2D").shape
				item.get_node("ShapeCast2D").shape.set_radius(shapenode.get_radius() + 100)
		
		# newly made turrets will have their range modified by selectedUpgrades
	if upgradeID == 7:
		Turret.criticalChance += 0.1
	if upgradeID == 8:
		Turret.maxHitPoints = Turret.maxHitPoints * 1.5
	if upgradeID == 9:
		pass
	if upgradeID == 10:
		pass
	if upgradeID == 11:
		pass
	if upgradeID == 12:
		pass
	if upgradeID == 13:
		pass
	if upgradeID == 14:
		pass
	if upgradeID == 15:
		pass
	
	
func UpdateSupply():
	for item in playerStructures:
		if item != null:
			if item.type == 3 or item.type == 1:
				item.UpdateSupply()
				
	
func MakeDamagePopup(where, amount, color = Color.DARK_RED):
	var newPopup =damagePopupScene.instantiate()
	newPopup.position = where
	newPopup.modulate = color
	newPopup.get_node("DamagePopup").text = "[center][b]" + str(amount) + "[/b][/center]"
	add_child(newPopup)


func GameOver():
	get_node("Camera/CanvasLayer/GameOverLabel").visible = true
	get_node("Camera/CanvasLayer/GameOverLabel/Label").text = "Score: " + str(totalValue)
	gameStarted = false
	emit_signal("game_ended")
	get_node("Camera/CanvasLayer/InGameUI").visible = false
	
	
# when the current operation can't be profitable anymore, the player can abort mission
# all remaining buildings will have some of their value returned
func AbortOperation():
	print("Abort operation!")
	
	for item in playerStructures:
		if item != null:
			operationFunds += buildingCosts[item.type] * 0.8
	
	for item in playerStructures:
		if item != null:
			item.queue_free()
		
	GameOver()
	
	
func UpdateMarketUI():
	marketUI.get_node("CrystalsUI/Label").text = "Crystals: " + str(Market.playerCrystals) + " / " + str(Market.maxCrystalStorage)
	marketUI.get_node("CrystalPriceUI/Label").text = str(Market.crystalPrice)
	
	marketUI.get_node("ConsumptionUI/SteelConsumed").text = "Steel: " + str(Market.totalConsumption[0])
	marketUI.get_node("ConsumptionUI/GasConsumed").text = "Gas: " + str(Market.totalConsumption[1])
	marketUI.get_node("ConsumptionUI/SemiconductorConsumed").text = "Semiconductor: " + str(Market.totalConsumption[2])
	
	marketUI.get_node("PriceUI/SteelConsumed").text = str(Market.marketPrices[0])
	marketUI.get_node("PriceUI/GasConsumed").text = str(Market.marketPrices[1])
	marketUI.get_node("PriceUI/SemiconductorConsumed").text = str(Market.marketPrices[2])
	
	marketUI.get_node("AutosellUI/Label").text = str(Market.minSellPrice)


func _on_build_turret_option_pressed(extra_arg_0):
	var str = "turret"
	if extra_arg_0 == 1:
		str = "HQ"
	if extra_arg_0 == 2:
		str = "Mining drill"
	if extra_arg_0 == 3:
		str = "Network Tower"
		
	print("Waiting for ", str, " build location!\n")
	buildType = extra_arg_0
	waitingForBuildLocation = true


func _on_mouse_entered_ui():
	mouseInUI = true
	
	
func _on_mouse_exited_ui():
	mouseInUI = false


func _on_attack_speed_button_pressed(extra_arg_0):
	selectedUnit.ChangeFireRate(extra_arg_0)
	get_node("Camera/CanvasLayer/InGameUI/UnitMenu").ShowUnit(selectedUnit)


func _on_option_button_item_selected(index):
	selectedUnit.ChangeAmmoType(get_node("Camera/CanvasLayer/InGameUI/UnitMenu/AmmoChoiceMenu/OptionButton").get_item_id(index))
	get_node("Camera/CanvasLayer/InGameUI/UnitMenu").ShowUnit(selectedUnit)
	mouseInUI = false


func _on_sell_button_pressed():
	operationFunds += buildingCosts[selectedUnit.type] * 0.8
	selectedUnit.hitPoints = 0
	selectedUnit = null
	mouseInUI = false


func _on_network_connection_button_pressed():
	waitingForTowerConnectionTarget = true
	print("Waiting for another tower to connect to!\n")


func _on_sell_crystals_button_pressed():
	Market.SellCrystals()
	Market.autoSell = not Market.autoSell
	UpdateMarketUI()
	


func _on_increase_pressed(extra_arg_0):
	if extra_arg_0 == true:
		Market.minSellPrice += 1
	else:
		Market.minSellPrice -= 1
		if Market.minSellPrice < 0:
			Market.minSellPrice = 0

	UpdateMarketUI()		
		
		
