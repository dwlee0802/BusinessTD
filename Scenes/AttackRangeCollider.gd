extends CharacterBody2D


func _physics_process(delta):
	print(get_slide_collision_count())
