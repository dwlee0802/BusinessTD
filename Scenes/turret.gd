extends CharacterBody2D

var hitPoints: int = 500
var maxHitPoints: int = 500

# 0: turret, 1: HQ, 2: Drill
var type: int = 0

var level: int = 1

var targets = []

var fireRate: float = 0.25
var fireRateHolder: float = 0

var healthBar
var healthBarSize: int = 75

var game

var isHQ: bool = false

var placedTile

var upkeep = [3, 5, 2]

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	
	if isHQ:
		maxHitPoints = 1500
		hitPoints = maxHitPoints
		healthBarSize = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		if isHQ:
			print("Game Over!")
			game.GameOver()
			
		var tiles
		
		if isHQ:
			tiles = game.GetSquare(placedTile, 7)
		else:
			tiles = game.GetSquare(placedTile, 3)
			
		for tile in tiles:
			for item in tile:
				item.occupied = false
			
		queue_free()
		
		
	if healthBar.scale.x > healthBarSize * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	if isHQ:
		game.operationFunds += -5 * delta
	else:
		game.operationFunds += -3 * delta
		
	
	
func _physics_process(delta):
	# choose the closest target
	targets = get_node("ShapeCast2D").GetColliders()
	
	if len(targets) == 0:
		return
		
	var currentTarget
	var currentDist = 10000
	
	for i in range(len(targets)):
		if i > 10:
			break
		if targets[i] == null:
			continue
		var thisDist
		thisDist = global_position.distance_to(targets[i].global_position)
		if thisDist < currentDist:
			currentTarget = targets[i]
			currentDist = thisDist
	
	# turn turret towards target
	if currentTarget != null:
		get_node("TurretBarrelSprite").rotation = global_position.angle_to_point(currentTarget.position)
	
		# attack target
		fireRateHolder += delta
		if fireRateHolder > fireRate:
			currentTarget.ReceiveHit(randi_range(20, 40))
			fireRateHolder = 0


func hit(damage):
	print("hit!")
	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.LAVENDER_BLUSH)
	
	
func _to_string():
	var output = ""
	if isHQ:
		output += "HQ at "
	else:
		output += "Turret at "
	
	output += str(placedTile)
	
	return output
