extends Button

var game
var menuBar
var menuPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	menuPanel = $MenuPanel
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _pressed():
	var prev = menuPanel.visible
	menuBar.HideAllMenus()
	
	if prev == false:
		menuPanel.visible = true
