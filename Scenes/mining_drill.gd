extends CharacterBody2D

var hitPoints: int = 250
var maxHitPoints: int = 250

var type: int = 2

var healthBar
var healthBarSize: int = 125

var profitGenerationPeriod: int = 1
var profitHolder: float = 1

var placedTile

var game


# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		var tiles = game.GetSquare(placedTile, 5)
		for tile in tiles:
			for item in tile:
				item.occupied = false
		
		queue_free()
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	profitHolder -= delta
	
	if profitHolder <= 0:
		game.operationFunds += 20
		profitHolder = profitGenerationPeriod
		game.MakeDamagePopup(position, 20, Color.YELLOW)
	
		
	
func hit(damage):
	print("drill took ", damage, " damage. Remaining HQ: ", hitPoints)
	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)
