extends CharacterBody2D

var hitPoints: int = 250
var maxHitPoints: int = 250

var type: int = 2

var healthBar
var healthBarSize: int = 125

var profitGenerationPeriod: float = 0.5
var profitHolder: float = 1

var placedTile

static var repairCost: int = 3
static var upkeep: int = 3
var upkeepHolder: float = 0

var revenueAmount: int = 100

var game

var isSupplied: bool = false

var sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	sprite = get_node("Sprite2D")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		var tiles = game.GetSquare(placedTile, 5)
		for tile in tiles:
			for item in tile:
				item.occupied = false
		
		queue_free()
		
	if hitPoints < maxHitPoints:
		hitPoints += 5 * delta
		game.operationFunds -= delta * repairCost * 5
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	if isSupplied:
		sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color.DIM_GRAY
	
	if isSupplied:
		profitHolder -= delta
		
		if profitHolder <= 0:
			game.operationFunds += revenueAmount
			profitHolder = profitGenerationPeriod
			game.MakeDamagePopup(position, 20, Color.LAWN_GREEN)
	
		
	
func hit(damage):
	print("drill took ", damage, " damage. Remaining HQ: ", hitPoints)
	hitPoints -= damage
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)
