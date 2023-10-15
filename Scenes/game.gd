extends Node2D


var turretScene = preload("res://Scenes/turret.tscn")

var waitingForBuildLocation: bool = false
var buildType

var mouseOnTile

var selectedTile

var mouseInUI: bool = false

var homeBlock

# how many tiles a building of type index takes up
# 0: turret, 1: HQ
var buildingSizeN = [3, 5]


# Called when the node enters the scene tree for the first time.
func _ready():
	homeBlock = get_node("MapBlock")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
						selectedTile.add_child(newTurret)
						
						for row in tiles:
							for tile in row:
								tile.occupied = true
						
						print("Spawned Turret at ", selectedTile)
						waitingForBuildLocation = false
						return
					
					


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
	


func _on_build_turret_option_pressed(extra_arg_0):
	print("Waiting for turret build location!\n")
	buildType = extra_arg_0
	waitingForBuildLocation = true


func _on_mouse_entered_ui():
	mouseInUI = true
	
func _on_mouse_exited_ui():
	mouseInUI = false
