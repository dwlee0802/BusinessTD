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

var mouseInUI: bool = false

var homeBlock
var edgeTiles = []

var playerStructures = []

# how many tiles a building of type index takes up
# 0: turret, 1: HQ, 2: Mining Drill
var buildingSizeN = [3, 7, 5]

var spawnRate: float = 2
var spawnRateHolder: float = 1
var spawnCount: float = 1

var gameStarted: bool = false
var gamePaused: bool = true

var operationFunds: float = -3000

var difficultyScale: float = 1.05

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
	get_node("Camera/CanvasLayer/InGameUI/MoneyLabel").text = "Funds: " + str(int(operationFunds))
	
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
		var result = space.intersect_point(param)
		
		
		if result:
			selectedTile = result[0].collider
			print(selectedTile)
		else:
			selectedTile = null
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
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
						
						print("Spawned Turret at ", selectedTile)
						playerStructures.append(newTurret)
						waitingForBuildLocation = false
						return
						
					elif buildType == 1:
						var newHQ = hqScene.instantiate()
						newHQ.isHQ = true
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
						
						playerStructures.append(newHQ)
						gameStarted = true
						
						return
					
					elif buildType == 2:
						if selectedTile.isDeposit:
							var newDrill = miningDrillScene.instantiate()
							add_child(newDrill)
							newDrill.position = selectedTile.position
							newDrill.placedTile = selectedTile
							
							for row in tiles:
								for tile in row:
									tile.occupied = true
									
							print("Spawned Mining Drill at ", selectedTile)
							
							playerStructures.append(newDrill)
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
	get_node("Camera/CanvasLayer/InGameUI/GameOverLabel").visible = true
	gameStarted = false
	

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
