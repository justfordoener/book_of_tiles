@tool
extends Node
@onready var main_manager = $".."
@onready var dualgrid_snap_tool = $dualgrid_snap_tool
@onready var trigrid_snap_tool = $trigrid_snap_tool
@onready var dualgrid : MeshInstance3D = $dualgrid
@onready var trigrid : MeshInstance3D = $trigrid
@onready var playgrid : MeshInstance3D = $playgrid
@onready var grid_check_button = $GridToggleControl/GridCheckButton

var DUALGRID_COLOR := Color("6B5E49")
var TRIGRID_COLOR := Color("586B50")
var PLAYGRID_COLOR := Color("586B59")

func ready() -> void:
	_setup_grid(dualgrid, DUALGRID_COLOR)
	_setup_grid(trigrid, TRIGRID_COLOR)
	_setup_grid(playgrid, PLAYGRID_COLOR)
	
	# generate tri, dual and playgrid
	
	
	
func _on_grid_check_button_toggled(toggled_on: bool) -> void:
	pass
	#if (toggled_on):
	#	trigrid_mesh.mesh = Grid.get_trigrid_array_mesh()
	#	trigrid_snap_tool.activated = true
	#	dualgrid_snap_tool.activated = false
	#	Grid.grid_state = 1
	#	_configure_mesh(trigrid_mesh, TRIGRID_COLOR)
	#else:
	#	dualgrid_mesh.mesh = Grid.get_dualgrid_array_mesh()
	#	dualgrid_snap_tool.activated = true
	#	trigrid_snap_tool.activated = false
	#	Grid.grid_state = 0
	#	_configure_mesh(dualgrid_mesh, DUALGRID_COLOR)
	#_show_grid(!toggled_on, dualgrid_mesh)
	#_show_grid(toggled_on, trigrid_mesh)
	#main_manager.toggle_grid()
	
func _setup_grid(mesh_instance : MeshInstance3D, color : Color) -> void:
	mesh_instance.set_visible(true)
	mesh_instance.mesh = Grid.get_dualgrid_array_mesh()
	Grid.configure_grid_mesh(mesh_instance, color)
	_show_grid(true, mesh_instance)

func _show_grid(value : bool, mesh : MeshInstance3D) -> void:
	if value:
		mesh.show()
		print("DEBUG: show ", mesh.name)
	else:
		mesh.hide()
		print("DEBUG: hide ", mesh.name)
