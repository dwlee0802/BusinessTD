extends Button

var game
var menuBar
var menuPanel

var crystalMarketTab
var steelMarketTab
var oilMarketTab
var semiconductorMarketTab

var crystalPriceGraph
var steelPriceGraph
var oilPriceGraph
var semiconductorPriceGraph

var marketCycles: int = 0

var selectedType: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	game.market_cycle.connect(RecordPrices)
	game.market_cycle.connect(UpdateUI)
	menuPanel = $MenuPanel
	crystalMarketTab = menuPanel.get_node("CrystalMarket")
	steelMarketTab = menuPanel.get_node("SteelMarket")
	oilMarketTab = menuPanel.get_node("OilMarket")
	semiconductorMarketTab = menuPanel.get_node("SemiconductorMarket")
	
	crystalPriceGraph = crystalMarketTab.get_node("PriceGraph").add_plot_item("", Color.PURPLE, 1.0)
	steelPriceGraph = steelMarketTab.get_node("PriceGraph").add_plot_item("", Color.SKY_BLUE, 1.0)
	oilPriceGraph = oilMarketTab.get_node("PriceGraph").add_plot_item("", Color.INDIAN_RED, 1.0)
	semiconductorPriceGraph = semiconductorMarketTab.get_node("PriceGraph").add_plot_item("", Color.LIME_GREEN, 1.0)
	
	
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
	
	UpdateUI()


func RecordPrices():
	crystalPriceGraph.add_point(Vector2(marketCycles, Market.crystalPrice))
	steelPriceGraph.add_point(Vector2(marketCycles, Market.marketPrices[Market.INGREDIENTS.Steel]))
	oilPriceGraph.add_point(Vector2(marketCycles, Market.marketPrices[Market.INGREDIENTS.Gas]))
	semiconductorPriceGraph.add_point(Vector2(marketCycles, Market.marketPrices[Market.INGREDIENTS.Semiconductors]))
	marketCycles += 1
	
	
func UpdateUI():
	var target
	if selectedType == 0:
		target = crystalMarketTab
		target.get_node("CurrentPrice").text = "Current Price: " + str(Market.crystalPrice)
		return
	if selectedType == 1:
		target = steelMarketTab
	if selectedType == 2:
		target = oilMarketTab
	if selectedType == 3:
		target = semiconductorMarketTab
	
	target.get_node("CurrentPrice").text = "Current Price: " + str(Market.marketPrices[selectedType - 1])
	
	target.get_node("TotalConsumption").text = "Total Demand: " + str(Market.totalConsumption[selectedType - 1])
	
	target.get_node("Consumption").text = "Consumption: " + str(Market.totalConsumption[selectedType - 1])
	
	target.get_node("Cost").text = "Cost: " + str(Market.totalConsumption[selectedType - 1] * Market.marketPrices[selectedType - 1])
