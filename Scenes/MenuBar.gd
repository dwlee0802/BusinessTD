extends Control

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent()
	HideAllMenus()
	get_node("BuildMenu/MenuPanel").visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func HideAllMenus():
	get_node("BuildMenu/MenuPanel").visible = false
	get_node("FinanceMenu/MenuPanel").visible = false
	get_node("UpgradesMenu/MenuPanel").visible = false
	get_node("MarketMenu/MenuPanel").visible = false
	get_node("CompetitionMenu/MenuPanel").visible = false
	get_node("SettingsMenu/MenuPanel").visible = false


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and Game.mouseInUI == false:
		if game.waitingForBuildLocation == false:
			HideAllMenus()
