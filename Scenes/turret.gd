extends CharacterBody2D

var hitPoints: int = 1

var targets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hitPoints <= 0:
		self.visible = false


func _physics_process(delta):
	pass
	
	
func hit():
	print("hit!")
