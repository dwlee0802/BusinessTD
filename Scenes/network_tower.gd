extends CharacterBody2D

var placedTile

var type: int = 3

var hitPoints: int = 250

var game

var isConnected: bool = false

var connectionRange
var supplyRange

func _ready():
	game = get_parent()
	connectionRange = get_node("ConnectionRange")
	supplyRange = get_node("SupplyRange")

func _process(delta):
	if game.waitingForBuildLocation == true and game.buildType == type:
		connectionRange.visible = true
		supplyRange.visible = false
	else:
		connectionRange.visible = false
		supplyRange.visible = true
		
	
func hit(damage):
	print("hit!")
#	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)


func UpdateConnection():
	var results = get_node("ConnectionShapeCast").GetColliders()
	for item in results:
		if item != null and item.type == type:
			if item.isConnected == false:
				item.isConnected = true
				item.UpdateConnection()

	
func UpdateSupply():
	var results = get_node("SupplyShapeCast").GetColliders()
	for item in results:
		if item != null and item.isSupplied == false:
			item.isSupplied = true
			
