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

var upperRightTile
var lowerRightTile
var upperLeftTile
var lowerLeftTile

var dist: int = 1000000

var game

var noise: float = 0
var noise2: float = 0
var noise3: float = 0

var pathToHQ

# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent()
		

func _to_string():
	var output 
	output = "tile at "
		
	output += str(row) + ", " + str(col) + "\n"
	
	output += "Passable: " + str(passable)
	
	return output + "\n"


func _print_coords():
	var output
	output = "[" + str(self.row) + ", " + str(self.col) + "]"
	return output
