extends Button

var game
var menuBar
var menuPanel

var profitGraph
var totalValueGraph
var incomeGraph
var costGraph

var consumptionUI
var profitUI
var netProfitUI

var marketCycles: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	menuBar = get_parent()
	game = menuBar.get_parent().get_parent().get_parent()
	menuPanel = $MenuPanel
	
	profitGraph = menuPanel.get_node("ProfitGraph").add_plot_item("", Color.LAWN_GREEN, 1.0)
	totalValueGraph = menuPanel.get_node("TotalValueGraph").add_plot_item("", Color.YELLOW, 1.0)
	incomeGraph = menuPanel.get_node("IncomeGraph").add_plot_item("Income", Color.GREEN, 1.0)
	costGraph = menuPanel.get_node("IncomeGraph").add_plot_item("Cost", Color.ORANGE_RED, 1.0)
	
	game.market_cycle.connect(RecordData)
	game.market_cycle.connect(UpdateUI)
	game.consumption_changed.connect(UpdateUI)
	
	consumptionUI = $MenuPanel/ConsumptionTitle
	profitUI = $MenuPanel/ProfitTitle
	netProfitUI = $MenuPanel/NetProfit/Label
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _pressed():
	var prev = menuPanel.visible
	menuBar.HideAllMenus()
	
	if prev == false:
		menuPanel.visible = true


func RecordData():
	profitGraph.add_point(Vector2(marketCycles, Market.income - Market.cost))
	totalValueGraph.add_point(Vector2(marketCycles, game.totalValue))
	incomeGraph.add_point(Vector2(marketCycles, Market.income))
	costGraph.add_point(Vector2(marketCycles, Market.cost))
	
	marketCycles += 1


func UpdateUI():
	consumptionUI.get_node("SteelConsumed").text = "Steel: " + str(Market.totalConsumption[Market.INGREDIENTS.Steel])
	consumptionUI.get_node("GasConsumed").text = "Gas: " + str(Market.totalConsumption[Market.INGREDIENTS.Gas])
	consumptionUI.get_node("SemiconductorConsumed").text = "Semiconductor: " + str(Market.totalConsumption[Market.INGREDIENTS.Semiconductors])
	
	var steelCost = Market.marketPrices[Market.INGREDIENTS.Steel] * Market.totalConsumption[Market.INGREDIENTS.Steel]
	var gasCost = Market.marketPrices[Market.INGREDIENTS.Gas] * Market.totalConsumption[Market.INGREDIENTS.Gas]
	var semiCost = Market.marketPrices[Market.INGREDIENTS.Semiconductors] * Market.totalConsumption[Market.INGREDIENTS.Semiconductors]
	consumptionUI.get_node("SteelCost").text = str(Market.marketPrices[Market.INGREDIENTS.Steel] * Market.totalConsumption[Market.INGREDIENTS.Steel])
	consumptionUI.get_node("GasCost").text = str(Market.marketPrices[Market.INGREDIENTS.Gas] * Market.totalConsumption[Market.INGREDIENTS.Gas])
	consumptionUI.get_node("SemiconductorCost").text = str(Market.marketPrices[Market.INGREDIENTS.Semiconductors] * Market.totalConsumption[Market.INGREDIENTS.Semiconductors])
	
	consumptionUI.get_node("SteelPrice").text = str(Market.marketPrices[Market.INGREDIENTS.Steel])
	consumptionUI.get_node("GasPrice").text = str(Market.marketPrices[Market.INGREDIENTS.Gas])
	consumptionUI.get_node("SemiconductorPrice").text = str(Market.marketPrices[Market.INGREDIENTS.Semiconductors])
	
	consumptionUI.get_node("TotalCost").text = str(steelCost + gasCost + semiCost)
	
	profitUI.get_node("SoldCrystals").text = "Crystal: " + str(Market.lastSoldCrystals)
	profitUI.get_node("TotalIncome").text = str(Market.crystalPrice * Market.lastSoldCrystals)
	profitUI.get_node("AverageSellPrice").text = str(Market.crystalPrice)
	
	netProfitUI.text = str(Market.crystalPrice * Market.lastSoldCrystals - steelCost - gasCost - semiCost)



func _on_graph_select_button_item_selected(index):
	menuPanel.get_node("ProfitGraph").visible = false
	menuPanel.get_node("TotalValueGraph").visible = false
	menuPanel.get_node("IncomeGraph").visible = false
	
	if index == 0:
		menuPanel.get_node("ProfitGraph").visible = true
	if index == 1:
		menuPanel.get_node("TotalValueGraph").visible = true
	if index == 2:
		menuPanel.get_node("IncomeGraph").visible = true
	
	game.mouseInUI = false
