extends CharacterBody2D

var placedTile

var type: int = 3

var hitPoints: int = 250

var game

var isConnected: bool = false

var connectionRange
var connectionArea
var supplyRange
var supplyArea

var spriteNode

var visited: bool = false

func _ready():
	game = get_parent()
	connectionRange = get_node("ConnectionRange")
	connectionArea = get_node("ConnectionArea")
	supplyRange = get_node("SupplyRange")
	supplyArea = get_node("SupplyArea")
	spriteNode = get_node("Sprite2D")

func _process(delta):
	if game.waitingForBuildLocation == true and game.buildType == type:
		connectionRange.visible = true
		supplyRange.visible = false
	else:
		connectionRange.visible = false
		supplyRange.visible = true
	
	if isConnected == false:
		connectionRange.visible = false
		supplyRange.visible = false
		spriteNode.modulate = Color.DIM_GRAY
		
	if hitPoints <= 0:
		var tiles
		tiles = game.GetSquare(placedTile, 3)
			
		for tile in tiles:
			for item in tile:
				item.occupied = false
		
		if game.selectedUnit == self:
			game.selectedUnit = null
			
		queue_free()
		
	
func hit(damage):
	print("hit!")
#	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)


func UpdateConnection():
	var results = connectionArea.get_overlapping_bodies()
	for item in results:
		if item != null and item.type == type:
			if item.visited == false:
				item.isConnected = true
				item.visited = true
				item.UpdateConnection()

	
func UpdateSupply():
	if isConnected == false:
		return
		
	var results = supplyArea.get_overlapping_bodies()
	for item in results:
		if item != null:
			if item.type == 0 or item.type == 2:
				if item.isSupplied == false:
					item.isSupplied = true
			
