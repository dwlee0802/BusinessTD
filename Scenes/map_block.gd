extends Node2D

class_name MapBlock

@export var boardWidth = 100
@export var boardHeight = 100

var depositSpawnRate: float = 0.005

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

# Called when the node enters the scene tree for the first time.
func _ready():
	tileScene = load("res://Scenes/tile.tscn")
	GenerateGameboard()

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
