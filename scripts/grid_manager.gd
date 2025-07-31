@tool
extends Node

@export var hexgrid_activated : bool = false: set = _on_hexgrid_check_button_toggled
@export var trigrid_activated : bool = false: set = _on_trigrid_check_button_toggled

@onready var hexgrid_snap_tool = $hexgrid_snap_tool
@onready var trigrid_snap_tool = $trigrid_snap_tool
@onready var hexgrid_mesh : MeshInstance3D = $hexgrid_mesh
@onready var trigrid_mesh : MeshInstance3D = $trigrid_mesh
@onready var hexgrid_check_button = $GridToggleControl/Hexgrid/HexgridCheckButton
@onready var trigrid_check_button = $GridToggleControl/Trigrid/TrigridCheckButton

var HEXGRID_COLOR := Color("6B5E49")
var TRIGRID_COLOR := Color("586B50")
	
func _on_hexgrid_check_button_toggled(toggled_on: bool) -> void:
	hexgrid_mesh.mesh = Grid.get_hexgrid_array_mesh()
	#if toggled_on and trigrid_snap_tool.activated:
	#	_on_trigrid_check_button_toggled(false)
	#	trigrid_check_button.set_pressed_no_signal(false)
	hexgrid_snap_tool.activated = toggled_on
	hexgrid_activated = toggled_on
	_configure_mesh(hexgrid_mesh, HEXGRID_COLOR)
	_show_grid(toggled_on, hexgrid_mesh)

func _on_trigrid_check_button_toggled(toggled_on: bool) -> void:
	trigrid_mesh.mesh = Grid.get_trigrid_array_mesh()
	#if toggled_on and hexgrid_snap_tool.activated:
	#	_on_hexgrid_check_button_toggled(false)
	#	hexgrid_check_button.set_pressed_no_signal(false)
	trigrid_snap_tool.activated = toggled_on
	trigrid_activated = toggled_on
	_configure_mesh(trigrid_mesh, TRIGRID_COLOR)
	_show_grid(toggled_on, trigrid_mesh)

func _configure_mesh(mesh : MeshInstance3D, color : Color) -> void:
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	mesh.material_override = material
	
func _show_grid(value : bool, mesh : MeshInstance3D) -> void:
	if value:
		mesh.show()
		print("show", mesh.name)
	else:
		mesh.hide()
		print("hide", mesh.name)
