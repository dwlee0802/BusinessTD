extends Node2D

class_name MapBlock

@export var boardWidth = 200
@export var boardHeight = 200

var depositSpawnRate: float = 0.002
var slowdownSpawnRate: float = 0.015

# Size of a square tile's one side's length in pixels
var initialTilesize = 32

var TILESIZE = 32

var tileScene

var blockTiles = []
var edgeTiles = []

var enemyScene = preload("res://Scenes/enemyUnit.tscn")
var enemyDifficultyIncrease: int = 0

var camera

var leftBlock
var rightBlock
var upperBlock
var lowerBlock

var noise = FastNoiseLite.new()
var noise2 = FastNoiseLite.new()
var noise3 = FastNoiseLite.new()

var pathfinding = AStar2D.new()

var game

signal wave_ready
var waveCount: int = 0
var spawned: int = 0
var waveEnemies = []

const SPAWN_PER_FRAME: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent()
	tileScene = load("res://Scenes/tile.tscn")
	GenerateGameboard()
	
	randomize()
	noise.seed = randi()
	noise2.seed = randi()
	noise2.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise2.noise_type = FastNoiseLite.TYPE_PERLIN
	noise3.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 3
	noise2.fractal_octaves = 3
	noise3.fractal_octaves = 5
	noise.fractal_gain = 2
	noise2.fractal_gain = 2
	noise3.fractal_gain = 5

	for x in range(0, boardWidth):
		for y in range(0, boardHeight):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			var noise_level2 = (noise2.get_noise_2d(x, y) + 1) / 2
			var noise_level3 = (noise3.get_noise_2d(x, y) + 1) / 2
			blockTiles[y][x].noise = noise_level
			blockTiles[y][x].noise2 = noise_level2
			blockTiles[y][x].noise3 = noise_level3
			
			var sprite = blockTiles[y][x].get_node("Sprite2D")
			
			if noise_level2 < 0.38:
				blockTiles[y][x].isSlowDown = true
				sprite.modulate = Color.WEB_GRAY
			if noise_level > 0.535:
				blockTiles[y][x].occupied = true
				blockTiles[y][x].passable = false
				sprite.modulate = Color.BLACK
			if noise_level > 0.8:
				blockTiles[y][x].isDeposit = true
				sprite.modulate = Color.PURPLE
			if noise_level3 > 0.79:
				blockTiles[y][x].isDeposit = true
				sprite.modulate = Color.PURPLE
				
	
	for items in blockTiles:
		for item in items:
			if item.passable == false:
				continue
			
			if item.leftTile != null and item.leftTile.passable != false:
				pathfinding.connect_points(item.id, item.leftTile.id)
			if item.rightTile != null and item.rightTile.passable != false:
				pathfinding.connect_points(item.id, item.rightTile.id)
			if item.upperTile != null and item.upperTile.passable != false:
				pathfinding.connect_points(item.id, item.upperTile.id)
			if item.lowerTile != null and item.lowerTile.passable != false:
				pathfinding.connect_points(item.id, item.lowerTile.id)
				
			# connect diagonal towers
			if item.lowerLeftTile != null and item.lowerLeftTile.passable != false and item.lowerTile.passable == true and  item.leftTile.passable == true:
				pathfinding.connect_points(item.id, item.lowerLeftTile.id)
			if item.lowerRightTile != null and item.lowerRightTile.passable != false and item.lowerTile.passable == true and  item.rightTile.passable == true:
				pathfinding.connect_points(item.id, item.lowerRightTile.id)
			if item.upperLeftTile != null and item.upperLeftTile.passable != false and item.upperTile.passable == true and  item.leftTile.passable == true:
				pathfinding.connect_points(item.id, item.upperLeftTile.id)
			if item.upperRightTile != null and item.upperRightTile.passable != false and item.upperTile.passable == true and  item.rightTile.passable == true:
				pathfinding.connect_points(item.id, item.upperRightTile.id)
	
	for i in range(1, boardWidth):
		if blockTiles[1][i].passable == true:
			game.edgeTiles.append(blockTiles[1][i])
		if blockTiles[-1][i].passable == true:
			game.edgeTiles.append(blockTiles[-1][i])
		if blockTiles[i][1].passable == true:
			game.edgeTiles.append(blockTiles[i][1])
		if blockTiles[i][-1].passable == true:
			game.edgeTiles.append(blockTiles[i][-1])
	
	edgeTiles = game.edgeTiles
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spawned < waveCount:
		for i in range(SPAWN_PER_FRAME):
			if spawned == waveCount:
				break
				
			var target = game.playerStructures.pick_random()
			while target == null:
				target = game.playerStructures.pick_random()
				
			var unit = SpawnEnemy(edgeTiles.pick_random(), target.placedTile, enemyDifficultyIncrease * 10)
			waveEnemies.append(unit)
			game.enemyCurrentCount += 1
			spawned += 1
	else:
		for item in waveEnemies:
			if item != null:
				item.waiting = false


func SpawnWave(count, healthIncrease = 0):
	waveEnemies = []
	spawned = 0
	waveCount = count
	enemyDifficultyIncrease = healthIncrease

# makes gameboard based on the parameters for board width and height
func GenerateGameboard():
	for i in range(boardHeight):
		var currentRow = []
		for j in range(boardWidth):
			var newTile = tileScene.instantiate()
			
			# roll to see if this tile is a mineral deposit
			if randf() < depositSpawnRate:
				newTile.isDeposit = true
				newTile.richness = (1 + randf())/2
				
			newTile.position = Vector2(j * TILESIZE, i * TILESIZE)
			newTile.row = i
			newTile.col = j
			newTile.id = j + i * boardWidth
			pathfinding.add_point(newTile.id, newTile.position, 1)
			
			if randf() < slowdownSpawnRate:
				newTile.isSlowDown = true
				
			add_child(newTile)
			currentRow.append(newTile)
			
			# make reference to neighbor tiles
			# left exists
			if j - 1 >= 0:
				newTile.leftTile = currentRow[j - 1]
				newTile.leftTile.rightTile = newTile
			# up exists
			if i - 1 >= 0:
				newTile.upperTile = blockTiles[i - 1][j]
				newTile.upperTile.lowerTile = newTile
		
		blockTiles.append(currentRow)
		
	ConnectDiagonals()


func ConnectDiagonals():
	for i in range(boardHeight):
		for j in range(boardWidth):
			if i > 0 and j > 0:
				blockTiles[i][j].upperLeftTile = blockTiles[i-1][j-1]
			if i < boardHeight - 1 and j < boardWidth - 1:
				blockTiles[i][j].lowerRightTile = blockTiles[i+1][j+1]
			if i > 0 and j < boardWidth - 1:
				blockTiles[i][j].upperRightTile = blockTiles[i-1][j+1]
			if i < boardHeight - 1 and j > 0:
				blockTiles[i][j].lowerLeftTile = blockTiles[i+1][j-1]
			
	
func SpawnEnemy(where, attackWhat, addHealth):
	var newUnit = enemyScene.instantiate()
	newUnit.position = where.position
	newUnit.attackTarget = attackWhat
	newUnit.maxHitPoints = 100 + addHealth
	newUnit.hitPoints = newUnit.maxHitPoints
	newUnit.startingTile = where
	newUnit.targetTile = attackWhat
	game.add_child(newUnit)
	
	return newUnit


func Randomize():	
	noise.seed = randi()
	noise2.seed = randi()
	noise2.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise2.noise_type = FastNoiseLite.TYPE_PERLIN
	noise3.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_octaves = 3
	noise2.fractal_octaves = 3
	noise3.fractal_octaves = 5
	noise.fractal_gain = 2
	noise2.fractal_gain = 2
	noise3.fractal_gain = 5

	for x in range(0, boardWidth):
		for y in range(0, boardHeight):
			var noise_level = (noise.get_noise_2d(x, y) + 1) / 2
			var noise_level2 = (noise2.get_noise_2d(x, y) + 1) / 2
			var noise_level3 = (noise3.get_noise_2d(x, y) + 1) / 2
			blockTiles[y][x].noise = noise_level
			blockTiles[y][x].noise2 = noise_level2
			blockTiles[y][x].noise3 = noise_level3
			
			var sprite = blockTiles[y][x].get_node("Sprite2D")
			
			# reset tile
			sprite.modulate = Color.WHITE
			blockTiles[y][x].isSlowDown = false
			blockTiles[y][x].passable = true
			blockTiles[y][x].occupied = false
			blockTiles[y][x].isDeposit = false
			
			if noise_level2 < 0.38:
				blockTiles[y][x].isSlowDown = true
				sprite.modulate = Color.WEB_GRAY
			if noise_level > 0.535:
				blockTiles[y][x].occupied = true
				blockTiles[y][x].passable = false
				sprite.modulate = Color.BLACK
			if noise_level > 0.8:
				blockTiles[y][x].isDeposit = true
				sprite.modulate = Color.PURPLE
			if noise_level3 > 0.79:
				blockTiles[y][x].isDeposit = true
				sprite.modulate = Color.PURPLE
				
	
	for items in blockTiles:
		for item in items:
			if item.passable == false:
				continue
			
			if item.leftTile != null and item.leftTile.passable != false:
				pathfinding.connect_points(item.id, item.leftTile.id)
			if item.rightTile != null and item.rightTile.passable != false:
				pathfinding.connect_points(item.id, item.rightTile.id)
			if item.upperTile != null and item.upperTile.passable != false:
				pathfinding.connect_points(item.id, item.upperTile.id)
			if item.lowerTile != null and item.lowerTile.passable != false:
				pathfinding.connect_points(item.id, item.lowerTile.id)
				
			# connect diagonal towers
			if item.lowerLeftTile != null and item.lowerLeftTile.passable != false and item.lowerTile.passable == true and  item.leftTile.passable == true:
				pathfinding.connect_points(item.id, item.lowerLeftTile.id)
			if item.lowerRightTile != null and item.lowerRightTile.passable != false and item.lowerTile.passable == true and  item.rightTile.passable == true:
				pathfinding.connect_points(item.id, item.lowerRightTile.id)
			if item.upperLeftTile != null and item.upperLeftTile.passable != false and item.upperTile.passable == true and  item.leftTile.passable == true:
				pathfinding.connect_points(item.id, item.upperLeftTile.id)
			if item.upperRightTile != null and item.upperRightTile.passable != false and item.upperTile.passable == true and  item.rightTile.passable == true:
				pathfinding.connect_points(item.id, item.upperRightTile.id)
	
	for i in range(1, boardWidth):
		if blockTiles[1][i].passable == true:
			game.edgeTiles.append(blockTiles[1][i])
		if blockTiles[-1][i].passable == true:
			game.edgeTiles.append(blockTiles[-1][i])
		if blockTiles[i][1].passable == true:
			game.edgeTiles.append(blockTiles[i][1])
		if blockTiles[i][-1].passable == true:
			game.edgeTiles.append(blockTiles[i][-1])
	
	edgeTiles = game.edgeTiles
	

func PixelCoordToTileIndex(position):
	return [position.y / TILESIZE as int, position.x / TILESIZE as int]
	
func TileIndexToPixelCoord(position):
	return Vector2(position[1] * TILESIZE + TILESIZE / 2, position[0] * TILESIZE + TILESIZE / 2)
