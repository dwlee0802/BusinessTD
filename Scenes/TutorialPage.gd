extends Panel

var intro
var controls

func _ready():
	intro = $IntroductionLabel
	controls = $ControlsLabel

func _on_dismiss_button_pressed():
	queue_free()


func _on_option_button_pressed(extra_arg_0):
	intro.visible = false
	controls.visible = false
	
	if extra_arg_0 == 0:
		intro.visible = true
	if extra_arg_0 == 1:
		controls.visible = true
