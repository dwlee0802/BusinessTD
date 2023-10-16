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
			pass
		else:
			if game.selectedUnit.type == 0:
				name = "Turret at "
			elif game.selectedUnit.type == 1:
				name = "HQ at "
			get_node("Name").text = name + str(game.selectedUnit.placedTile.row) + ", " + str(game.selectedUnit.placedTile.col)
			get_node("CurrentLevel").text = "Level: " + str(game.selectedUnit.level)
			get_node("DamageRange").text = "Damage Range: " + str(20 + (game.selectedUnit.level-1) * 10) + " - " + str(40 + (game.selectedUnit.level-1) * 10)
			get_node("Upkeep").text = "Upkeep: " + str(game.selectedUnit.upkeep[game.selectedUnit.type])
	else:
		visible = false
