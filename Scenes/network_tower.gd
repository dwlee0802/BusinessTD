extends CharacterBody2D

var placedTile

var type: int = 3

var hitPoints: float = 250
var maxHitPoints: int = 250

static var repairCost: int = 3
static var upkeep: int = 3
var upkeepHolder: float = 0

var repairHolder: float = 0

var game

var isConnected: bool = false

var connectionRange
var connectionArea
var supplyRange
var supplyArea

var healthBar
var healthBarSize = 70

var spriteNode

var visited: bool = false

var buildTime: float = 3
var	buildTimeLabel

func _ready():
	game = get_parent()
	connectionRange = get_node("ConnectionRange")
	connectionArea = get_node("ConnectionArea")
	supplyRange = get_node("SupplyRange")
	supplyArea = get_node("SupplyArea")
	spriteNode = get_node("Sprite2D")
	healthBar = get_node("Healthbar")
	buildTimeLabel = get_node("BuildTime")
	

func _process(delta):
	if hitPoints <= 0:
		var tiles
		tiles = game.GetSquare(placedTile, 3)
			
		for tile in tiles:
			for item in tile:
				item.occupied = false
		
		if game.selectedUnit == self:
			game.selectedUnit = null
			
		queue_free()
	
	repairHolder += delta
	if repairHolder > 1:
		if hitPoints < maxHitPoints:
			hitPoints += 10
			game.operationFunds -= repairCost * 10
		else:
			hitPoints = maxHitPoints
		repairHolder = 0
		
	healthBar.scale.x = healthBarSize * hitPoints / maxHitPoints
		
	if buildTime > 0:
		buildTime -= delta
		spriteNode.modulate = Color.DIM_GRAY
		buildTimeLabel.text = str(snapped(buildTime, 0.001))
		isConnected = false
		return
	else:
		buildTimeLabel.visible = false
		
		
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
	
		
	spriteNode.modulate = Color.WHITE
		
	
func hit(damage):
	print("hit!")
	hitPoints -= damage
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
			
