extends CharacterBody2D

var hitPoints: int = 100
var maxHitPoints: int = 100

var attackTarget

@export var speed: int = 800

var healthBar

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints < 0:
		queue_free()
	
	if healthBar.scale.x > 32 * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	
func _physics_process(delta):
	if attackTarget != null:
		velocity = Vector2(speed,0).rotated(position.angle_to_point(attackTarget.position))
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			collision.get_collider().hit(hitPoints)
			
			queue_free()
	else:
		attackTarget = game.playerStructures.pick_random()
			
			
func ReceiveHit(amount):
	hitPoints -= amount
#	healthBar.scale.x = 32 * hitPoints / maxHitPoints
	game.MakeDamagePopup(position, amount)
