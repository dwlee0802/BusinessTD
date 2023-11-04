extends Control

class_name Market

# price of one crystal
var crystalPrice = 1200

# holds the prices of ingredients
var marketPrices = [100, 50, 150]

enum INGREDIENTS {Steel, Gas, Semiconductors}

# time between market update
var updateTime: float = 5
var updateTimeHolder: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	updateTimeHolder -= delta
	if updateTimeHolder <= 0:
		updateTimeHolder = updateTime
		UpdatePrices()
		UpdateMarketUI()
		

# called every updateTime seconds
func UpdatePrices():
	pass
	
	
func UpdateMarketUI():
	pass
