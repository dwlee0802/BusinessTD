extends Node2D

func _ready():
	get_node("CPUParticles2D").one_shot = true
	
	
func _on_Timer_timeout():
	queue_free()
