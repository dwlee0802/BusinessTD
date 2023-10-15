extends Node2D


var turretScene = preload("res://Scenes/turret.tscn")

var waitingForBuildLocation: bool = false
var buildType

var mouseOnTile

var selectedTile

var mouseInUI: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and mouseInUI == false:
		# Raytrace at mouse position and get tile
		var space = get_viewport().world_2d.direct_space_state
		var param = PhysicsPointQueryParameters2D.new()
		param.position = get_global_mouse_position()
		var result = space.intersect_point(param)
		
		
		if result:
			selectedTile = result[0].collider
			print(selectedTile)
		else:
			selectedTile = null
			print("Nothing Selected!\n")
			
			
		if waitingForBuildLocation:
			if selectedTile == null:
				print("No location selected. Cancelling.")
				waitingForBuildLocation = false
			else:
				print("Make turret at: ")
				print(selectedTile, "\n")


# returns a list of tiles in a N x N square centered at center tile
# if not possible, returns null
func Get_Square(center, N):
	var output = []
	var start = center
	
	# go to top left corner
	for i in range(N/2):
		pass
		
	


func _on_build_turret_option_pressed(extra_arg_0):
	print("Waiting for turret build location!\n")
	buildType = extra_arg_0
	waitingForBuildLocation = true


func _on_mouse_entered_ui():
	mouseInUI = true
	
func _on_mouse_exited_ui():
	mouseInUI = false
