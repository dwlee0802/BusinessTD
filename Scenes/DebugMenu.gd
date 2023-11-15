extends Panel

var enemyScene = preload("res://Scenes/enemyUnit.tscn")
var spawnEnemy: bool = false

var game


# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if spawnEnemy:
		if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and Game.mouseInUI == false:
			# spawn enemy at mouse click position
			var space = get_viewport().world_2d.direct_space_state
			var param = PhysicsPointQueryParameters2D.new()
			param.position = get_global_mouse_position()
			print(param.position)
			param.collision_mask = 4
			var result = space.intersect_point(param)
			
			var selectedTile
			
			if len(result) >= 1:
				selectedTile = result[0].collider
				
				SpawnEnemy(game.selectedTile, game.playerStructures.pick_random().placedTile)
				
				print("Spawned Enemy at ", game.selectedTile.row, ", " , game.selectedTile.col, "\n")
			

func _on_spawn_enemy_toggled(button_pressed):
	spawnEnemy = button_pressed


func SpawnEnemy(where, attackWhat, addHealth = 0):
	var newUnit = enemyScene.instantiate()
	newUnit.position = where.position
	newUnit.attackTarget = attackWhat
	newUnit.maxHitPoints = 100 + addHealth
	newUnit.hitPoints = newUnit.maxHitPoints
	newUnit.startingTile = where
	newUnit.targetTile = attackWhat
	game.add_child(newUnit)
	game.enemyCurrentCount += 1


func _on_infinite_money_hack_pressed():
	game.operationFunds += 10000
