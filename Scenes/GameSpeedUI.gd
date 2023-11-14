extends Control


func _on_game_speed_button_pressed(extra_arg_0):
	for i in range(get_child_count()):
		if i == extra_arg_0:
			continue
		
		get_child(i).button_pressed = false
		
		if extra_arg_0 == 0:
			Engine.time_scale = 0
		if extra_arg_0 == 1:
			Engine.time_scale = 1
		if extra_arg_0 == 2:
			Engine.time_scale = 1.5
		if extra_arg_0 == 3:
			Engine.time_scale = 2
		
