extends Label

var game

var ammoChoiceMenu

var nameUI
var sellButton
var upkeepUI
var attackSpeedMenu
var networkButton

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent().get_parent()
	ammoChoiceMenu = get_node("AmmoChoiceMenu")
	nameUI = get_node("Name")
	sellButton = get_node("SellButton")
	upkeepUI = get_node("Upkeep")
	attackSpeedMenu = get_node("AttackSpeedMenu")
	networkButton = get_node("InsideNetwork")


func _process(delta):
	if game.selectedUnit == null:
		visible = false

		
func ShowUnit(unit = game.selectedUnit):
	visible = true
	
	var selectedUnit = unit
	var unitName = ""
	networkButton.visible = false
	sellButton.visible = false
	upkeepUI.visible = false
	ammoChoiceMenu.visible = false
	attackSpeedMenu.visible = false
	
	# turret
	if selectedUnit.type == 0:
		ammoChoiceMenu.get_node("OptionButton").selected = selectedUnit.ammoType
		ammoChoiceMenu.visible = true
		attackSpeedMenu.visible = true
		sellButton.visible = true
		upkeepUI.visible = true
		upkeepUI.text = "Upkeep: " + str(selectedUnit.upkeep[selectedUnit.type]) + " per second"
		
		unitName = "Turret at " + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
		var buttons = []
		buttons.append(get_node("AttackSpeedMenu/Low"))
		buttons.append(get_node("AttackSpeedMenu/Base"))
		buttons.append(get_node("AttackSpeedMenu/High"))
		
		for i in range(3):
			if game.selectedUnit.fireRateMode == i:
				buttons[i].disabled = true
			else:
				buttons[i].disabled = false
	
	# HQ
	elif selectedUnit.type == 1:
		unitName = "HQ at " + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
		ammoChoiceMenu.get_node("OptionButton").selected = selectedUnit.ammoType
		ammoChoiceMenu.visible = true
		attackSpeedMenu.visible = true
		sellButton.visible = false
		upkeepUI.visible = true
		upkeepUI.text = "Upkeep: " + str(selectedUnit.upkeep[selectedUnit.type]) + " per second"
		
		var buttons = []
		buttons.append(get_node("AttackSpeedMenu/Low"))
		buttons.append(get_node("AttackSpeedMenu/Base"))
		buttons.append(get_node("AttackSpeedMenu/High"))
		
		for i in range(3):
			if game.selectedUnit.fireRateMode == i:
				buttons[i].disabled = true
			else:
				buttons[i].disabled = false
	
	# Drill
	elif selectedUnit.type == 2:
		sellButton.visible = true
		upkeepUI.visible = true
		unitName = "Mining Drill at " + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
		upkeepUI.text = "Upkeep: 2 per second"
	
	# network tower
	elif selectedUnit.type == 3:
		sellButton.visible = true
		upkeepUI.visible = true
		unitName = "Network Tower at " + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
		upkeepUI.text = "Upkeep: 2 per second"
		networkButton.visible = true
		networkButton.text = "Connection: " + str(selectedUnit.isConnected)
		
	else:
		print("ERROR! Wrong building type.")
	
	nameUI.text = unitName
