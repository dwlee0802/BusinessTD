extends Control

class_name Market

# price of one crystal
static var crystalPrice = 200
static var lastSoldCrystals: int = 0

# player's crystals
static var playerCrystals: int = 0
static var maxCrystalStorage: int = 250

# holds the prices of ingredients
static var marketPrices = [200, 100, 50, 150]

static var priceHistory = []

static var baseConsumption = [[2, 0, 2], [2, 0, 2], [1, 2, 1], [1, 0, 1]]
static var totalConsumption = [0, 0, 0]

# holds the amount of ingredients supplied to the market
# supply is increased linearly naturaly throughout the game.
# This rate of increase can be increased by player investments.
static var supplyAmount = [0, 0, 0]

# how many were sold during last market cycle
static var buyOrders = [0, 0, 0]

enum INGREDIENTS { Steel, Gas, Semiconductors }

static var autoSell: bool = false
static var minSellPrice: int = 100

static var income: int = 0
static var cost: int = 0


static var game



# called every updateTime seconds
static func UpdatePrices():
	# temporary completely random function
	crystalPrice = randi_range(100, 200)
	marketPrices[0] = randi_range(75, 125)
	marketPrices[1] = randi_range(25, 75)
	marketPrices[2] = randi_range(100, 200)
	lastSoldCrystals = 0
	income = 0
	cost = 0
	
# called when player presses sell stored crystals button. Sells all in storage by current price.
static func SellCrystals():
	var amount = playerCrystals * crystalPrice
	game.operationFunds += amount
	income += amount
	lastSoldCrystals += playerCrystals
	playerCrystals = 0


# calculates the supply amount for each ingredient type for the next cycle.
static func SupplyGrowth():
	pass


static func UpdateConsumption():
	totalConsumption = [0, 0, 0]
	for item in game.playerStructures:
		if is_instance_valid(item):
			var modifier = 1
			if item.type == 0 or item.type == 1:
				if item.fireRateMode == 2:
					modifier = 2
				if item.ammoType == 1:
					totalConsumption[0] += modifier
				elif item.ammoType == 2 or item.ammoType == 3:
					totalConsumption[1] += modifier
					
			totalConsumption[0] += baseConsumption[item.type][0] * modifier
			totalConsumption[1] += baseConsumption[item.type][1] * modifier
			totalConsumption[2] += baseConsumption[item.type][2] * modifier


static func Consumption():
	for i in range(3):
		var amount = totalConsumption[i] * marketPrices[i]
		game.operationFunds -= amount
		cost += amount
	
	
static func AddCrystals(amount):
	playerCrystals += amount
	print("Added ", amount, " crystals.")
	
	# if storage is full, sell the overflow amount at current price
	if playerCrystals > maxCrystalStorage:
		var overflow = playerCrystals - maxCrystalStorage
		game.operationFunds += overflow * crystalPrice
		print("Sold overflow of ", overflow, " at price of ", crystalPrice, "\n")
		playerCrystals = maxCrystalStorage


static func ModifierFromDifference(diff):
	pass
	
	
static func RecordPrices():
	var newData = []
	newData.append(crystalPrice)
	newData.append(marketPrices[0])
	newData.append(marketPrices[1])
	newData.append(marketPrices[2])
	
	priceHistory.append(newData)
