extends CharacterBody2D

var hitPoints: int = 100
var maxHitPoints: int = 100

var attackTarget

@export var speed: int = 200
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

var sprite
var hitAnimation
var explosionAnimation

var dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	healthBar = get_node("Healthbar")
	game = get_parent()
	game.game_ended.connect(GameEnded)
	pathfinding = game.homeBlock.pathfinding
	path = startingTile.pathToHQ
	sprite = get_node("UnitSprite")
	hitAnimation = get_node("AnimationPlayer")
	explosionAnimation = get_node("ExplosionArea/ExplosionSprite/AnimationPlayer")
	path = pathfinding.get_id_path(startingTile.id, targetTile.id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		return
		
	if hitPoints <= 0:
		var eff = enemyDeathEffect.instantiate()
		eff.global_position = position
		game.add_child(eff)
		Die()
		queue_free()
	
	if healthBar.scale.x > 32 * hitPoints / maxHitPoints:
		healthBar.scale.x -= delta * 140


var tempHolder: float = 0
	
func _physics_process(delta):
	if dead:
		return
		
	if len(path) - 1 > pathCount:
		if position.distance_to(pathfinding.get_point_position(path[pathCount])) < 2:
			pathCount += 1
	else:
		# no path!
		hitPoints = 0
		return
		
	velocity = Vector2(speed * speedModifier,0).rotated(position.angle_to_point(pathfinding.get_point_position(path[pathCount])))
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		collision.get_collider().hit(hitPoints)
		
		game.add_child(enemyDeathEffect.instantiate())
		queue_free()
		
	tempHolder += delta
	if tempHolder > 0.5:
		# slow down if tile is a slowdown tile
		var space = get_viewport().world_2d.direct_space_state
		var param = PhysicsPointQueryParameters2D.new()
		param.position = position
		param.collision_mask = 4
		var result = space.intersect_point(param)
		
		if result[0] != null and result[0].collider.isSlowDown == true:
			speedModifier = 0.5
		else:
			speedModifier = 1
		
		tempHolder = 0
	
			
func ReceiveHit(amount, isCrit = false, isHE = false):
	hitPoints -= amount
#	healthBar.scale.x = 32 * hitPoints / maxHitPoints
	if isCrit:
		game.MakeDamagePopup(position, amount, Color.DARK_ORANGE)
	else:
		game.MakeDamagePopup(position, amount, Color.RED)
		
	sprite.modulate = Color.RED
	get_node("Timer").start(0.1)
	hitAnimation.play("hit_animation")
	
	if isHE:
		for item in get_node("ExplosionArea").get_overlapping_bodies():
			if item == self:
				continue
			item.ReceiveHit(randi_range(int(amount/4), amount), isCrit)
			
		explosionAnimation.play("explosionAnimation")
	
			

func GameEnded():
	queue_free()


func Die():
	game.enemyCurrentCount -= 1
	sprite.visible = false
	set_physics_process(false)
	healthBar.visible = false
	dead = true


func Revive():
	path = pathfinding.get_id_path(startingTile.id, targetTile.id)
	pathCount = 0
	sprite.visible = true
	set_physics_process(true)
	healthBar.visible = true
	dead = false
	

func _on_timer_timeout():
	sprite.modulate = Color.WHITE
