@tool
extends Node
@onready var main_manager = $".."
@onready var hexgrid_snap_tool = $hexgrid_snap_tool
@onready var trigrid_snap_tool = $trigrid_snap_tool
@onready var hexgrid_mesh : MeshInstance3D = $hexgrid_mesh
@onready var trigrid_mesh : MeshInstance3D = $trigrid_mesh
@onready var grid_check_button = $GridToggleControl/GridCheckButton

@export var HEXGRID_COLOR := Color("6B5E49")
@export var TRIGRID_COLOR := Color("586B50")

func ready() -> void:
	_on_grid_check_button_toggled(false)
	
func _on_grid_check_button_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		trigrid_mesh.mesh = Grid.get_trigrid_array_mesh()
		trigrid_snap_tool.activated = true
		hexgrid_snap_tool.activated = false
		Grid.dual_grid_state = 1
		_configure_mesh(trigrid_mesh, TRIGRID_COLOR)
	else:
		hexgrid_mesh.mesh = Grid.get_hexgrid_array_mesh()
		hexgrid_snap_tool.activated = true
		trigrid_snap_tool.activated = false
		Grid.dual_grid_state = 0
		_configure_mesh(hexgrid_mesh, HEXGRID_COLOR)
	_show_grid(!toggled_on, hexgrid_mesh)
	_show_grid(toggled_on, trigrid_mesh)
	main_manager.toggle_grid()
	

func _configure_mesh(mesh : MeshInstance3D, color : Color) -> void:
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material = ORMMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	mesh.material_override = material
	
func _show_grid(value : bool, mesh : MeshInstance3D) -> void:
	if value:
		mesh.show()
		print("DEBUG: show ", mesh.name)
	else:
		mesh.hide()
		print("DEBUG: hide ", mesh.name)
