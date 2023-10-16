extends CharacterBody2D

var attackTarget

@export var speed: int = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	velocity = Vector2(speed,0).rotated(position.angle_to_point(attackTarget.position))
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		collision.get_collider().hit()
		
		queue_free()
