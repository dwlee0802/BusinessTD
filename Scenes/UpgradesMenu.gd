extends Control

var upgradeCost: int = 2500
var upgradeCostUI

var rerollCost: int = 2000
var rerollButton

var options = [-1, -2, -3, -4]
var optionsUI

var game
var menuBar
var menuPanel

var upgradesDictionary
var upgradesFilePath: String = "res://Data/upgrades.json"
var companiesDictionary
var companiesFilePath: String = "res://Data/companies.json"

const UPGRADE_COUNT: int = 9
var OPTIONS_COUNT: int = 3


func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	menuPanel = $MenuPanel
	upgradeCostUI = get_node("MenuPanel/CostLabel")
	rerollButton = get_node("MenuPanel/RerollButton")
	optionsUI = get_node("MenuPanel/Title")
	
	# read in json files
	var file1 = FileAccess.open(upgradesFilePath, FileAccess.READ)
	var file2 = FileAccess.open(companiesFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	var content_as_text2 = file2.get_as_text()
	upgradesDictionary = parse_json(content_as_text1)
	companiesDictionary = parse_json(content_as_text2)
	
	GenerateUpgradeOptions()
	UpdateUI()
	

func parse_json(text):
	return JSON.parse_string(text)

	
func GenerateUpgradeOptions(amount = 3):
	options[0] = randi_range(0, UPGRADE_COUNT - 1)
	options[1] = randi_range(0, UPGRADE_COUNT - 1)
	while options[0] == options[1]:
		options[1] = randi_range(0, UPGRADE_COUNT - 1)
	
	options[2] = randi_range(0, UPGRADE_COUNT - 1)
	while options[2] == options[0] or options[2] == options[1]:
		options[2] = randi_range(0, UPGRADE_COUNT - 1)
	
	
func UpdateUI():
	upgradeCostUI.text = "Cost: " + str(upgradeCost)
	rerollButton.text = "Reroll: " + str(rerollCost)
	
	# Update the cards to show the options
	for i in range(OPTIONS_COUNT):
		var item = optionsUI.get_child(i)
		item.get_node("Info").text = upgradesDictionary.Upgrades[options[i]].name + "\n" + upgradesDictionary.Upgrades[options[i]].Description
		

func _on_option_pressed(extra_arg_0):
	game.ReceiveUpgrades(options[extra_arg_0])
	
	game.operationFunds -= upgradeCost
	upgradeCost *= 2
	
	game._on_mouse_exited_ui()
	GenerateUpgradeOptions()
	UpdateUI()


func _on_reroll_button_pressed():
	game.operationFunds -= rerollCost
	rerollCost *= 2
	GenerateUpgradeOptions()
	UpdateUI()


func _on_pressed():
	var prev = menuPanel.visible
	menuBar.HideAllMenus()
	
	if prev == false:
		menuPanel.visible = true
