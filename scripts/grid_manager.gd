extends Node

@onready var play_layer = $abstract_grid/play_layer
@onready var dual_layer = $abstract_grid/dual_layer
@onready var face_layer = $abstract_grid/face_layer
@onready var edge_layer = $abstract_grid/edge_layer
@onready var corn_layer = $abstract_grid/corn_layer

@export var play_module : PackedScene
@export var dual_module : PackedScene
@export var face_module : PackedScene
@export var edge_module : PackedScene
@export var corn_module : PackedScene
@export var camera_path : NodePath

var active_layer : GridLayer
var active_module : PackedScene
var preview_instance : Node3D
var camera : Camera3D

func _ready():
	_init_grid()

func _init_grid():
	active_module = play_module
	active_layer = play_layer
	camera = get_node(camera_path) as Camera3D
	
func _process(_delta):
	if !camera or !preview_instance or !active_layer:
		push_warning("WARNING: camera or preview_instance or active_layer is not assigned.")
		return
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, 0)
	var hit : Vector3 = plane.intersects_ray(ray_origin, ray_dir)
	preview_instance.visible = not _is_mouse_over_ui_rect(mouse_pos)
	if hit != null:
		preview_instance.global_position = active_layer.snap_to_layer(hit)
		if Input.is_action_just_pressed("mouse_wheel_down"):
			preview_instance.rotate_y(deg_to_rad(60))
		if Input.is_action_just_pressed("mouse_wheel_up"):
			preview_instance.rotate_y(deg_to_rad(-60))
		if Input.is_action_just_pressed("mouse_left"):
			_spawn_instance(preview_instance.global_position, preview_instance.rotation.y)

func _create_preview_instance():
	if !active_module:
		push_warning("WARNING: active_module is not assigned.")
		return
	preview_instance = active_module.instantiate()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 1, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true
	# set transparent material to preview mesh instance
	for child in preview_instance.get_children():
		if child is MeshInstance3D:
			child.material_override = material
	add_child(preview_instance)

func _spawn_instance(position: Vector3, rotation : float):
	if !active_module:
		push_warning("active_module is not assigned.")
		return
	var instance = active_module.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	instance.global_rotation.y = rotation

func _is_mouse_over_ui_rect(mouse_pos : Vector2) -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered != null and hovered.get_global_rect().has_point(mouse_pos)
	
func set_active_layer():
	pass
