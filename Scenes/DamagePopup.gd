extends RichTextLabel

var lifespan: float = 1

var offset: int = 10

func _ready():
	position += Vector2(randf_range(-1, 1) * offset, randf_range(-1, 1))
	position += Vector2(-50, -25)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position + Vector2(0, -16 * delta)
