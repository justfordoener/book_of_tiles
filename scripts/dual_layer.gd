extends GridLayer

func _ready():
	build_layer()

func build_layer():
	pass
	
func activate_layer():
	print_debug("dual layer activated")
	layer_color = DUAL_LAYER_COLOR

func snap_to_grid(point : Vector3) -> Vector3:
	return point #TODO
