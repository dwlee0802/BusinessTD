extends CharacterBody2D

var hitPoints: int = 1
var maxHitPoints: int = 1

var attackTarget

@export var speed: int = 100
@export var speedModifier: float = 1

var healthBar

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	game.game_ended.connect(GameEnded)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints < 0:
		queue_free()
	
	if healthBar.scale.x > 32 * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140
	
	
func _physics_process(delta):
	if attackTarget != null:
		velocity = Vector2(speed * speedModifier,0).rotated(position.angle_to_point(attackTarget.position))
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			collision.get_collider().hit(hitPoints)
			
			queue_free()
	else:
		attackTarget = game.playerStructures.pick_random()
	
	
	# slow down if tile is such tile
	var space = get_viewport().world_2d.direct_space_state
	var param = PhysicsPointQueryParameters2D.new()
	param.position = position
	param.collision_mask = 4
	var result = space.intersect_point(param)
	
	if result[0].collider.isSlowDown == true:
		speedModifier = 0.5
	else:
		speedModifier = 1
	
			
func ReceiveHit(amount):
	hitPoints -= amount
#	healthBar.scale.x = 32 * hitPoints / maxHitPoints
	game.MakeDamagePopup(position, amount, Color.RED)
	

func GameEnded():
	queue_free()
