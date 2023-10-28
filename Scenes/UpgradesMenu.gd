extends Control

var upgradeCost: int = 10000
var upgradeCostUI

var rerollCount: int = 0
var rerollCost: int = 4000
var rerollButton

var options = [-1, -2, -3, -4]
var optionsUI

var game

var upgradesDictionary
var upgradesFilePath: String = "res://Data/upgrades.json"
var companiesDictionary
var companiesFilePath: String = "res://Data/companies.json"

const UPGRADE_COUNT: int = 16
var OPTIONS_COUNT: int = 3


func _ready():
	game = get_parent().get_parent().get_parent().get_parent().get_parent()
	upgradeCostUI = get_node("Options/CostLabel")
	rerollButton = get_node("Options/RerollButton")
	optionsUI = get_node("Options")
	
	# read in json files
	var file1 = FileAccess.open(upgradesFilePath, FileAccess.READ)
	var file2 = FileAccess.open(companiesFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	var content_as_text2 = file2.get_as_text()
	upgradesDictionary = parse_json(content_as_text1)
	companiesDictionary = parse_json(content_as_text2)
	
	print(upgradesDictionary.Upgrades[0].name)
	
	GenerateUpgradeOptions()
	UpdateUI()
	

func parse_json(text):
	return JSON.parse_string(text)

	
func GenerateUpgradeOptions(amount = 3):
	while amount > 0:
		amount -= 1
		
		options[0] = randi_range(0, UPGRADE_COUNT)
		options[1] = randi_range(0, UPGRADE_COUNT)
		while options[0] == options[1]:
			options[1] = randi_range(0, UPGRADE_COUNT)
		
		options[2] = randi_range(0, UPGRADE_COUNT)
		while options[0] == options[1] and options[0] == options[2] and options[1] == options[2]:
			options[2] = randi_range(0, UPGRADE_COUNT)
	
	
func UpdateUI():
	upgradeCostUI.text = "Cost: " + str(upgradeCost)
	rerollButton.text = "Reroll: " + str(rerollCost)
	
	# Update the cards to show the options
	for i in range(OPTIONS_COUNT):
		var item = optionsUI.get_child(1 + i)
		item.get_node("Info").text = upgradesDictionary.Upgrades[options[i]].name + "\n" + upgradesDictionary.Upgrades[options[i]].Description
		
	
func _on_upgrades_menu_button_pressed():
	var options = get_node("Options")
	options.visible = not options.visible


func _on_option_pressed(extra_arg_0):
	var options = get_node("Options")
	options.visible = false
	
	game.ReceiveUpgrades()
