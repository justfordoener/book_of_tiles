extends Node

@export var scene_to_spawn: PackedScene
@export var camera_path: NodePath  # Assign your Camera3D here in the editor

var preview_instance: Node3D
var camera: Camera3D

func _ready():
	camera = get_node(camera_path) as Camera3D
	_create_preview_instance()

func _process(_delta):
	if !camera or !preview_instance:
		return
	var mouse_pos = get_viewport().get_mouse_position()
	if _is_mouse_over_ui_rect(mouse_pos):
		preview_instance.visible = false
		return
	else:
		preview_instance.visible = true
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, 0)  # y = 0
	var hit = plane.intersects_ray(ray_origin, ray_dir)
	
	if hit != null:
		var snapped_hit = Grid.euclidic_snap_to_hexgrid(hit)
		preview_instance.global_position = snapped_hit
		
		if Input.is_action_just_pressed("mouse_left"):
			_spawn_instance(snapped_hit, preview_instance.rotation.y)
		if Input.is_action_just_pressed("mouse_wheel_down"):
			preview_instance.rotate_y(deg_to_rad(60))
		if Input.is_action_just_pressed("mouse_wheel_up"):
			preview_instance.rotate_y(deg_to_rad(-60))

func _is_mouse_over_ui_rect(mouse_pos : Vector2) -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	return hovered != null and hovered.get_global_rect().has_point(mouse_pos)
	
func _create_preview_instance():
	if !scene_to_spawn:
		push_warning("scene_to_spawn is not assigned.")
		return
	preview_instance = scene_to_spawn.instantiate()
	preview_instance.visible = true
	preview_instance.name = "PreviewInstance"

	# Apply transparency to all MeshInstance3Ds in the preview
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 1, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.flags_transparent = true

	for child in preview_instance.get_children():
		if child is MeshInstance3D:
			child.material_override = material

	add_child(preview_instance)

func _spawn_instance(position: Vector3, rotation : float):
	if !scene_to_spawn:
		push_warning("scene_to_spawn is not assigned.")
		return
	var instance = scene_to_spawn.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	instance.global_rotation.y = rotation
