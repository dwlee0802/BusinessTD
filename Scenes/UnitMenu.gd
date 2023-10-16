extends Button

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.selectedUnit != null:
		visible = true
		var name
		if game.selectedUnit.type == 2:
				name = "Mining Drill at "
				get_node("SellButton").visible = false
				get_node("UpgradeButton").visible = false
				get_node("DamageRange").visible = true
				get_node("CurrentLevel").visible = false
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("DamageRange").text = "Profits: 20 per second"
				get_node("Upkeep").text = "Upkeep: 2"
		else:
			if game.selectedUnit.type == 0:
				name = "Turret at "
				get_node("SellButton").visible = true
				get_node("UpgradeButton").visible = true
				get_node("DamageRange").visible = true
				get_node("CurrentLevel").visible = true
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("CurrentLevel").text = "Level: " + str(game.selectedUnit.level)
				get_node("DamageRange").text = "Damage Range: " + str(20 + (game.selectedUnit.level-1) * 10) + " - " + str(40 + (game.selectedUnit.level-1) * 10)
				get_node("Upkeep").text = "Upkeep: " + str(game.selectedUnit.upkeep[game.selectedUnit.type])
			elif game.selectedUnit.type == 1:
				name = "HQ at "
				get_node("SellButton").visible = false
				get_node("UpgradeButton").visible = false
				get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
				get_node("CurrentLevel").visible = false
				get_node("DamageRange").text = "Damage Range: " + str(20 + (game.selectedUnit.level-1) * 10) + " - " + str(40 + (game.selectedUnit.level-1) * 10)
				get_node("Upkeep").text = "Upkeep: " + str(game.selectedUnit.upkeep[game.selectedUnit.type])
	else:
		visible = false
