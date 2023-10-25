extends CharacterBody2D

var hitPoints: int = 100
var maxHitPoints: int = 100

var attackTarget

@export var speed: int = 100
@export var speedModifier: float = 1

var enemyDeathEffect = preload("res://Scenes/explosion_effect.tscn")

var healthBar

var game
var pathfinding

var path

var startingTile
var targetTile
var pathCount: int = 0
var nextTile

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	game.game_ended.connect(GameEnded)
	pathfinding = game.homeBlock.pathfinding
	
	path = pathfinding.get_id_path(startingTile.id, targetTile.id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints < 0:
		var eff = enemyDeathEffect.instantiate()
		eff.global_position = position
		game.add_child(eff)
		queue_free()
	
	if healthBar.scale.x > 32 * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140

var tempHolder: float = 0
	
func _physics_process(delta):
	if tempHolder > 0.2:
		tempHolder = 0
		
		if len(path) > pathCount:
			position = pathfinding.get_point_position(path[pathCount])
		else:
			hitPoints = 0
			
		pathCount += 1
		
	tempHolder += delta
	
	"""
	if attackTarget != null:
		velocity = Vector2(speed * speedModifier,0).rotated(position.angle_to_point(pathfinding.get_point_position(path[pathCount])))
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			collision.get_collider().hit(hitPoints)
			
			game.add_child(enemyDeathEffect.instantiate())
			queue_free()
	else:
		attackTarget = game.playerStructures.pick_random()
	"""
	
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
