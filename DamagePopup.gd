extends RichTextLabel

var lifespan: float = 1

var offset: int = 10

func _ready():
	position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * offset
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lifespan < 0:
		queue_free()
		
	lifespan -= delta
	
	position = position + Vector2(0, -8 * delta)
