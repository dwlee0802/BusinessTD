extends ShapeCast2D


func GetColliders():
	var output = []
	for i in range(get_collision_count()):
		output.append(get_collider(i))
	return output
