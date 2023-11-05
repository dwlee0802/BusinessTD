extends Control

class_name Market

# price of one crystal
static var crystalPrice = 120
static var lastSoldCrystals

# player's crystals
static var playerCrystals: int = 0
static var maxCrystalStorage: int = 250

# holds the prices of ingredients
static var marketPrices = [100, 50, 150]

static var baseConsumption = [[2, 0, 2], [2, 0, 2], [1, 2, 1], [1, 0, 1]]
static var totalConsumption = [0, 0, 0]

# holds the amount of ingredients supplied to the market
# supply is increased linearly naturaly throughout the game.
# This rate of increase can be increased by player investments.
static var supplyAmount = [0, 0, 0]

# how many were sold during last market cycle
static var buyOrders = [0, 0, 0]

enum INGREDIENTS { Steel, Gas, Semiconductors }

static var game


# called every updateTime seconds
static func UpdatePrices():
	# temporary completely random function
	crystalPrice = randi_range(60, 180)
	marketPrices[0] = randi_range(75, 125)
	marketPrices[1] = randi_range(25, 75)
	marketPrices[2] = randi_range(100, 200)
	
	
# called when player presses sell stored crystals button. Sells all in storage by current price.
static func SellCrystals():
	pass
	

# calculates the supply amount for each ingredient type for the next cycle.
static func SupplyGrowth():
	pass


static func UpdateConsumption():
	totalConsumption = [0, 0, 0]
	for item in game.playerStructures:
		totalConsumption[0] += baseConsumption[item.type][0]
		totalConsumption[1] += baseConsumption[item.type][1]
		totalConsumption[2] += baseConsumption[item.type][2]


static func Consumption():
	pass
	
	
static func AddCrystals(amount):
	playerCrystals += amount
	print("Added ", amount, " crystals.")
	
	# if storage is full, sell the overflow amount at current price
	if playerCrystals > maxCrystalStorage:
		var overflow = playerCrystals - maxCrystalStorage
		game.operationFunds += overflow * crystalPrice
		print("Sold overflow of ", overflow, " at price of ", crystalPrice, "\n")
		playerCrystals = maxCrystalStorage
