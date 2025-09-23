class_name GridLayer extends Node3D

@export var PLAY_LAYER_COLOR := Color.ORANGE
@export var DUAL_LAYER_COLOR := Color.DARK_RED
@export var FACE_LAYER_COLOR := Color.CYAN
@export var EDGE_LAYER_COLOR := Color.LIME_GREEN
@export var CORN_LAYER_COLOR := Color.YELLOW

var layer_color = Color.BLACK
var current_module

func _ready():
	pass

func build_layer():
	pass

func activate_layer():
	print_debug("abstract init grid")
	pass
	
func snap_to_layer(point : Vector3) -> Vector3:
	return point
