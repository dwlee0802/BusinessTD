extends Button

var game
var menuBar
var menuPanel

var crystalMarketTab
var steelMarketTab
var oilMarketTab
var semiconductorMarketTab


# Called when the node enters the scene tree for the first time.
func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	menuPanel = $MenuPanel
	crystalMarketTab = menuPanel.get_node("CrystalMarket")
	steelMarketTab = menuPanel.get_node("SteelMarket")
	oilMarketTab = menuPanel.get_node("OilMarket")
	semiconductorMarketTab = menuPanel.get_node("SemiconductorMarket")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _pressed():
	var prev = menuPanel.visible
	menuBar.HideAllMenus()
	
	if prev == false:
		menuPanel.visible = true


func _on_option_button_item_selected(index):
	crystalMarketTab.visible = false
	steelMarketTab.visible = false
	oilMarketTab.visible = false
	semiconductorMarketTab.visible = false
	
	if index == 0:
		crystalMarketTab.visible = true
	if index == 1:
		steelMarketTab.visible = true
	if index == 2:
		oilMarketTab.visible = true
	if index == 3:
		semiconductorMarketTab.visible = true
		
