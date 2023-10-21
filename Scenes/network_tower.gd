extends CharacterBody2D

var placedTile

var type: int = 3

var hitPoints: int = 250

var game

var isConnected: bool = false

func _ready():
	game = get_parent()

func hit(damage):
	print("hit!")
#	hitPoints -= 100
	game.MakeDamagePopup(position, damage, Color.WEB_PURPLE)


func UpdateConnection():
	pass
	
	
func UpdateSupply():
	pass
