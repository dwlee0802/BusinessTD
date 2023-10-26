extends Control

var upgradeCost: int = 10000
var upgradeCostUI

var rerollCount: int = 0
var rerollCost: int = 4000
var rerollButton

var option1
var option2
var option3

var game

func _ready():
	game = get_parent().get_parent().get_parent().get_parent().get_parent()
	upgradeCostUI = get_node("Options/CostLabel")
	rerollButton = get_node("Options/RerollButton")
	UpdateUI()


func _process(delta):
	pass
	
	
func UpdateUI():
	upgradeCostUI.text = "Cost: " + str(upgradeCost)
	rerollButton.text = "Reroll: " + str(rerollCost)
	
	
func _on_upgrades_menu_button_pressed():
	var options = get_node("Options")
	options.visible = not options.visible

func _on_option_pressed(extra_arg_0):
	pass # Replace with function body.
