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

var camera

var leftBlock
var rightBlock
var upperBlock
var lowerBlock

var noise = FastNoiseLite.new()
var noise2 = FastNoiseLite.new()
var noise3 = FastNoiseLite.new()

var pathfinding = AStar2D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	tileScene = load("res://Scenes/tile.tscn")
	GenerateGameboard()
	
	for items in blockTiles:
		for item in items:
			if item.leftTile != null:
				pathfinding.connect_points(item.id, item.leftTile.id)
			if item.rightTile != null:
				pathfinding.connect_points(item.id, item.rightTile.id)
			if item.upperTile != null:
				pathfinding.connect_points(item.id, item.upperTile.id)
			if item.lowerTile != null:
				pathfinding.connect_points(item.id, item.lowerTile.id)
				
			if item.passable == false:
				pathfinding.set_point_disabled(item.id)
	
	
	randomize()
	noise.seed = 2
	noise2.seed = 5
	noise2.seed = 7
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
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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


func PixelCoordToTileIndex(position):
	return [position.y / TILESIZE as int, position.x / TILESIZE as int]
	
func TileIndexToPixelCoord(position):
	return Vector2(position[1] * TILESIZE + TILESIZE / 2, position[0] * TILESIZE + TILESIZE / 2)
