extends Node2D

class_name Tile

# Script to hold individual tile variables
@export var col: int = 0
@export var row: int = 0

var occupied: bool = false

var upperTile
var lowerTile
var rightTile
var leftTile

var dist: int = 1000000

var game


# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	game.mouseOnTile = self


func _to_string():
	var output 
	output = "tile at "
		
	output += str(row) + ", " + str(col) + "\n"
	
	return output

