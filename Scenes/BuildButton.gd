extends Button

var game

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent().get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game.operationFunds < 0:
		get_node("BuildOptionsMenu/MiningDrillButton").disabled = true
		get_node("BuildOptionsMenu/TurretButton").disabled = true
		get_node("BuildOptionsMenu/NetworkTowerButton").disabled = true
	else:
		get_node("BuildOptionsMenu/MiningDrillButton").disabled = false
		get_node("BuildOptionsMenu/TurretButton").disabled = false
		get_node("BuildOptionsMenu/NetworkTowerButton").disabled = false
		


func _pressed():
	
	var menu = get_node("BuildOptionsMenu")
	
	menu.visible = not menu.visible
