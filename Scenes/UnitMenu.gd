extends Label

var game

var ammoChoiceMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent().get_parent()
	ammoChoiceMenu = get_node("AmmoChoiceMenu/OptionButton")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.selectedUnit != null:
		visible = true
		var name
		if game.selectedUnit.type == 2:
				name = "Mining Drill at "
				get_node("SellButton").visible = true
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("Upkeep").text = "Upkeep: 2"
		else:
			ammoChoiceMenu.selected = game.selectedUnit.ammoType
			
			var buttons = []
			buttons.append(get_node("AttackSpeedMenu/Low"))
			buttons.append(get_node("AttackSpeedMenu/Base"))
			buttons.append(get_node("AttackSpeedMenu/High"))
			for i in range(3):
				if game.selectedUnit.fireRateMode == i:
					buttons[i].disabled = true
				else:
					buttons[i].disabled = false
					
			if game.selectedUnit.type == 0:
				name = "Turret at "
				get_node("SellButton").visible = true
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("Upkeep").text = "Upkeep: " + str(game.selectedUnit.fireRateMode - 1 + game.selectedUnit.upkeep[game.selectedUnit.type])
			elif game.selectedUnit.type == 1:
				name = "HQ at "
				get_node("SellButton").visible = false
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("Upkeep").text = "Upkeep: " + str(game.selectedUnit.fireRateMode - 1 + game.selectedUnit.upkeep[game.selectedUnit.type])
	else:
		visible = false
