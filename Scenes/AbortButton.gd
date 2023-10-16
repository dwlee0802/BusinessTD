extends Button

var game

var pressCount: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _pressed():
	get_node("Buttons").visible = true
	

func _on_confirm_button_pressed():
	game.AbortOperation()
	visible = false


func _on_cancel_button_pressed():
	get_node("Buttons").visible = false
