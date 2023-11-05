extends CharacterBody2D

var hitPoints: int = 250
var maxHitPoints: int = 250

var type: int = 2

var healthBar
var healthBarSize: int = 125

var profitGenerationPeriod: float = 1
var profitHolder: float = 1

var placedTile

static var repairCost: int = 3
var repairHolder: float = 1
static var upkeep: int = 10
var upkeepHolder: float = 0

var revenueAmount: int = 100

var game

var isSupplied: bool = false

var sprite

var buildTime: float = 10
var buildTimeLabel

var particles


# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	sprite = get_node("Sprite2D")
	buildTimeLabel = get_node("BuildTime")
	particles = get_node("CPUParticles2D")
	game.game_ended.connect(GameEnded)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		var tiles = game.GetSquare(placedTile, 5)
		for tile in tiles:
			for item in tile:
				item.occupied = false
		
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
		sprite.modulate = Color.DIM_GRAY
		buildTimeLabel.text = str(snapped(buildTime, 0.001))
		
		return
	else:
		buildTimeLabel.visible = false
		
	sprite.modulate = Color.DIM_GRAY
		
	if isSupplied:
		sprite.modulate = Color.WHITE
		particles.emitting = true
	else:
		sprite.modulate = Color.DIM_GRAY
		particles.emitting = false
	
	if isSupplied:
		profitHolder -= delta
		
		if profitHolder <= 0:
#			revenueAmount = randi_range(50, 150)
#			game.operationFunds += revenueAmount
			var mined = randi_range(1, 7)
			Market.AddCrystals(mined)
			profitHolder = profitGenerationPeriod
			game.MakeDamagePopup(position, mined, Color.PURPLE)
			game.UpdateMarketUI()
		
	
func hit(damage):
	print("Drill took ", damage, " damage. Remaining HP: ", hitPoints, "\n")
	hitPoints -= damage
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)


func GameEnded():
	hitPoints = 0
