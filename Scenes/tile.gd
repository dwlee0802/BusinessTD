extends Node2D

class_name Tile

# Script to hold individual tile variables
@export var col: int = 0
@export var row: int = 0

@export var id: int = 0

var occupied: bool = false
var passable: bool = true

var isDeposit: bool = false
var richness: float = 1

var isSlowDown: bool = false

var upperTile
var lowerTile
var rightTile
var leftTile

var dist: int = 1000000

var game

var noise: float = 0
var noise2: float = 0
var noise3: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent()
	if isDeposit:
		pass
#		get_node("Sprite2D").modulate = Color.PURPLE
	elif isSlowDown:
		pass
#		get_node("Sprite2D").modulate = Color.SLATE_GRAY
	else:
		pass
#		get_node("Sprite2D").modulate = Color.ANTIQUE_WHITE


func _process(delta):
	if noise2 < 0.34:
		get_node("Sprite2D").modulate = Color.SLATE_GRAY
		isSlowDown = true
	if noise > 0.55:
		get_node("Sprite2D").modulate = Color.BLACK
		occupied = true
		passable = false
	if noise > 0.8:
		get_node("Sprite2D").modulate = Color.PURPLE
		isDeposit = true
	if noise3 > 0.79:
		get_node("Sprite2D").modulate = Color.PURPLE
		isDeposit = true
		

func _to_string():
	var output 
	output = "tile at "
		
	output += str(row) + ", " + str(col) + "\n"
	output += str(noise)
	
	return output

