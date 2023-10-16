extends CharacterBody2D

var hitPoints: int = 500
var maxHitPoints: int = 500

var targets = []

var fireRate: float = 0.25
var fireRateHolder: float = 0

var healthBar

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		pass
		queue_free()
	
	
func _physics_process(delta):
	# choose the closest target
	targets = get_node("ShapeCast2D").GetColliders()
	
	if len(targets) == 0:
		return
		
	var currentTarget
	var currentDist = 10000
	
	for item in targets:
		if item == null:
			continue
		var thisDist
		thisDist = global_position.distance_to(item.global_position)
		if thisDist < currentDist:
			currentTarget = item
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
	hitPoints -= damage
	healthBar.scale.x = 75 * hitPoints / maxHitPoints
	game.MakeDamagePopup(position, damage)
