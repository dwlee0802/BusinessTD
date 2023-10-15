extends Camera2D

var tileSize

var game


# Called when the node enters the scene tree for the first time.
func _ready():
	game = get_parent()
	var board = game.get_node("MapBlock")
	tileSize = board.TILESIZE
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = zoom * 1.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = zoom * 0.9
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			position += Vector2(0, -tileSize * 4)
		if event.keycode == KEY_S:
			position -= Vector2(0, -tileSize * 4)
		if event.keycode == KEY_A:
			position += Vector2(-tileSize * 4, 0)
		if event.keycode == KEY_D:
			position += Vector2(tileSize * 4, 0)

func FocusOnTile(tile):
	if tile != null:
		position = tile.position + Vector2(-tileSize,-tileSize)
