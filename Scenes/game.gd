extends Node2D


var turretScene = preload("res://Scenes/turret.tscn")
var hqScene = preload("res://Scenes/HQ.tscn")
var enemyScene = preload("res://Scenes/enemyUnit.tscn")
var damagePopupScene = preload("res://Scenes/damage_popup.tscn")
var miningDrillScene = preload("res://Scenes/mining_drill.tscn")

var waitingForBuildLocation: bool = false
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
var buildingSizeN = [3, 7, 5]

# upfront cost of buildings
var buildingCosts = [800, 1500, 500]

var spawnRate: float = 2
var spawnRateHolder: float = 1
var spawnCount: float = 10

var gameStarted: bool = false
var gamePaused: bool = true

signal game_ended

var operationFunds: float = 5000
var highestValuePoint: float = 5000

# takes into account the cash in value of buildings
var totalValue: float = 5000

var difficultyScale: float = 1.01

# Called when the node enters the scene tree for the first time.
func _ready():
	homeBlock = get_node("MapBlock")
	
	get_node("Camera").FocusOnTile(homeBlock.blockTiles[int(homeBlock.boardWidth/2)][int(homeBlock.boardWidth/2)])
	
	for i in range(1, homeBlock.boardWidth):
		edgeTiles.append(homeBlock.blockTiles[1][i])
		edgeTiles.append(homeBlock.blockTiles[-1][i])
		edgeTiles.append(homeBlock.blockTiles[i][1])
		edgeTiles.append(homeBlock.blockTiles[i][-1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not playerStructures.is_empty():
		var assets = 0
		for item in playerStructures:
			if item != null:
				assets += buildingCosts[item.type] * 0.8
			
		totalValue = operationFunds + assets
		
	if totalValue > highestValuePoint:
		highestValuePoint = totalValue
		
	get_node("Camera/CanvasLayer/InGameUI/MostFundsLabel").text = "Highest Value: " + str(int(highestValuePoint))
	get_node("Camera/CanvasLayer/InGameUI/MoneyLabel").text = "Current Funds: " + str(int(operationFunds))
	get_node("Camera/CanvasLayer/InGameUI/Total Value").text = "Current Value: " + str(int(totalValue))
	
	if not playerStructures.is_empty() and gameStarted == true:
		gameStarted = true
		spawnRateHolder += delta
		
		if spawnRateHolder > spawnRate:
			# randomly spawn enemies at the edge of the map
			for i in range(int(spawnCount)):
				SpawnEnemy(edgeTiles.pick_random().position, playerStructures.pick_random())
			spawnCount *= difficultyScale
			spawnRateHolder = 0
	

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
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
						
						print("Spawned Turret at ", selectedTile)
						playerStructures.append(newTurret)
						
						operationFunds -= buildingCosts[buildType]
						
						waitingForBuildLocation = false
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
						
						operationFunds -= buildingCosts[buildType]
						playerStructures.append(newHQ)
						gameStarted = true
						
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
							
						
					
					


# returns a list of tiles in a N x N square centered at center tile
# if not possible, returns null
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
	

func SpawnEnemy(where, attackWhat):
	var newUnit = enemyScene.instantiate()
	newUnit.position = where
	newUnit.attackTarget = attackWhat
	add_child(newUnit)
	
	
func MakeDamagePopup(where, amount, color = Color.DARK_RED):
	var newPopup =damagePopupScene.instantiate()
	newPopup.position = where
	newPopup.text = str(amount)
	newPopup.modulate = color
	add_child(newPopup)


func GameOver():
	get_node("Camera/CanvasLayer/GameOverLabel").visible = true
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
	

func _on_build_turret_option_pressed(extra_arg_0):
	var str = "turret"
	if extra_arg_0 == 1:
		str = "HQ"
	if extra_arg_0 == 2:
		str = "mining drill"
		
	print("Waiting for ", str, " build location!\n")
	buildType = extra_arg_0
	waitingForBuildLocation = true


func _on_mouse_entered_ui():
	mouseInUI = true
	
	
func _on_mouse_exited_ui():
	mouseInUI = false


func _on_attack_speed_button_pressed(extra_arg_0):
	selectedUnit.ChangeFireRate(extra_arg_0)


func _on_option_button_item_selected(index):
	selectedUnit.ChangeAmmoType(index)


func _on_sell_button_pressed():
	operationFunds += buildingCosts[selectedUnit.type] * 0.8
	selectedUnit.hitPoints = 0
