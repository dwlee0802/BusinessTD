extends Button

var game
var menuBar
var menuPanel

# Called when the node enters the scene tree for the first time.
func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	menuPanel = $MenuPanel


# turn on and off build buttons based on player funds
func _process(delta):
	if game.operationFunds < 0:
		get_node("MenuPanel/DrillButton").disabled = true
		get_node("MenuPanel/TurretButton").disabled = true
		get_node("MenuPanel/NetworkTowerButton").disabled = true
	else:
		get_node("MenuPanel/DrillButton").disabled = false
		get_node("MenuPanel/TurretButton").disabled = false
		get_node("MenuPanel/NetworkTowerButton").disabled = false
		

func _pressed():
	var prev = menuPanel.visible
	menuBar.HideAllMenus()
	
	if prev == false:
		menuPanel.visible = true


func MadeHQ():
	get_node("MenuPanel/HQButton").visible = false
	get_node("MenuPanel/DrillButton").visible = true
	get_node("MenuPanel/TurretButton").visible = true
	get_node("MenuPanel/NetworkTowerButton").visible = true
