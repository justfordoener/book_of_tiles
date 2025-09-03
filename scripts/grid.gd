@tool
extends Node
# the hexagonal grid uses 
# - flat top orientation
# - an even-q layout
# - cube coordinates for hexagon calculations
# for reference use: https://www.redblobgames.com/grids/hexagons/#basics

class hexagon_cell:
	var state : int  #bitwise superposition of cell states (63 = 111111)

class triangle_cell:
	var state : int

var CELL_SIZE := 2
var GRID_RADIUS := 15
var GRID_HEIGHT := 0.5
var CENTER_TILE_EUCLIDIC := Vector3(0,0,0)
var CENTER_TILE_CUBIC := Vector3(0,0,0)
var CUBIC_DIRECTION := {	
	0: Vector3(0, -1,  1),	# top
	1: Vector3(1, -1,  0),	# top right
	2: Vector3(1,  0, -1),	# bottom right
	3: Vector3(0,  1,  -1),	# bottom
	4: Vector3(-1, 1,  0),	# bottom left
	5: Vector3(-1,  0,  1)	# top left
}
var TILE_ROTATION_VALUE := {
	0:    CUBIC_DIRECTION[0],	# facing top
	300:  CUBIC_DIRECTION[1],	# facing top right
	240:  CUBIC_DIRECTION[2],	# facing bottom right
	180:  CUBIC_DIRECTION[3],	# facing bottom
	120:  CUBIC_DIRECTION[4],	# facing bottom left
	60:   CUBIC_DIRECTION[5]	# facing top left
}
var dual_grid_state = 0 # 0 = hexgrid, 1 = trigrid

var hexgrid = {} # in cube coords
var trigrid = {} # in euclidic coords

func _ready() -> void:
	initialize_grid()
	print("init grid completed")

func initialize_grid() -> void:
	#hexgrid
	hexgrid[CENTER_TILE_CUBIC] = hexagon_cell.new()
	for ring in cubic_spiral(CENTER_TILE_CUBIC, GRID_RADIUS):
		for pos in ring:
			var new_cell = hexagon_cell.new()
			new_cell.state = 0
			hexgrid[pos] = new_cell
	
	#trigrid
	for point in hexgrid:
		for direction in range(6):
			var corner = get_euclicdic_hexagon_corner(cubic_to_euclidic(point), direction)
			if !trigrid.has(corner):
				var new_cell = triangle_cell.new()
				new_cell.state = 0
				trigrid[corner] = new_cell
	
# ------------------- draw functions --------------------

func get_hexgrid_array_mesh() -> ArrayMesh:
	var hexgrid_array_mesh : ArrayMesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()
	for point in hexgrid:
		var corners = []
		for direction in range(6):
			corners.append(get_euclicdic_hexagon_corner(cubic_to_euclidic(point), direction))
		verts.append_array(corners)
		var base_index = verts.size() - 6
		for direction in range(6):
			indices.append(base_index + direction)
			indices.append(base_index + ((direction + 1) % 6))
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	hexgrid_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_array)
	return hexgrid_array_mesh

func get_trigrid_array_mesh() -> ArrayMesh:
	var trigrid_array_mesh : ArrayMesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	var indices = PackedInt32Array()
	for point in hexgrid:
		var corners = []
		for index in range(CUBIC_DIRECTION.size()):
			corners.append(cubic_to_euclidic(point+CUBIC_DIRECTION[index]))
		verts.append(cubic_to_euclidic(point))
		verts.append_array(corners)
		var base_index = verts.size() - 7
		for direction in range(6):
			indices.append(base_index)
			indices.append(base_index + direction + 1)
			indices.append(base_index + ((direction + 1) % 6) + 1)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices
	trigrid_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_array)
	return trigrid_array_mesh


# ------------------- helper functions -------------------


func euclidic_snap_to_hexgrid(point) -> Vector3:
	var cube_coordinate_rounded : Vector3 = Grid.cubic_round(Grid.euclidic_to_cubic(point))
	var point_new : Vector3 = Grid.cubic_to_euclidic(cube_coordinate_rounded)
	return Vector3(point_new.x, point.y, point_new.z)
	
func euclidic_snap_to_trigrid(point : Vector3) -> Vector3:
	var hexagon_center = euclidic_snap_to_hexgrid(point)
	var min_dist = INF
	var closest_corner : Vector3 = Vector3.ZERO
	for direction in range(6):
		var corner = get_euclicdic_hexagon_corner(hexagon_center, direction)
		var dist = point.distance_to(corner)
		if dist < min_dist:
			closest_corner = corner
			min_dist = dist
	return closest_corner + Vector3(0, 0.5, 0)
	
func get_euclicdic_hexagon_corner(euclidic_center : Vector3, direction : int) -> Vector3:
	var angle_degree = 60 * direction + 30
	var angle_radian = deg_to_rad(angle_degree)
	return euclidic_center + Vector3(
		CELL_SIZE * cos(angle_radian),
		0,
		CELL_SIZE * sin(angle_radian)
	)

func get_cubic_hexagon_corner(cubic_center : Vector3, direction : int) -> Vector3:
	return Vector3.ZERO
	
func cubic_distance_from_to(from: Vector3, to: Vector3):
	var distance : Vector3 = Vector3.ZERO
	distance.x = to.x - from.x
	distance.y = to.y - from.y
	distance.z = to.z - from.z
	return distance

func euclidic_to_cubic(point: Vector3):
	var hexagon : Vector3 = Vector3.ZERO
	hexagon.x = ( 2./3 * point.z) / CELL_SIZE
	hexagon.y = (-1./3 * point.z + sqrt(3)/3 * point.x) / CELL_SIZE
	hexagon.z = -hexagon.x-hexagon.y
	return cubic_round(hexagon)
	
func cubic_to_euclidic(hexagon: Vector3):
	var point : Vector3 = Vector3.ZERO
	point.x = CELL_SIZE * (sqrt(3)/2 * hexagon.x + sqrt(3) * hexagon.y)
	point.y = 0
	point.z = CELL_SIZE * 	   (3./2 * hexagon.x)
	return point

func cubic_round(frac_hexagon: Vector3) -> Vector3:
	var round_x = int(round(frac_hexagon.x))
	var round_y = int(round(frac_hexagon.y))
	var round_z = int(round(frac_hexagon.z))
	var diff_x = abs(round_x - frac_hexagon.x)
	var diff_y = abs(round_y - frac_hexagon.y)
	var diff_z = abs(round_z - frac_hexagon.z)
	if diff_x > diff_y and diff_x > diff_z:
		round_x = -round_y-round_z
	else: if diff_y > diff_z:
		round_y = -round_x-round_z
	else:
		round_z = -round_x-round_y
	return Vector3(round_x, round_y, round_z)

func cubic_ring(center : Vector3, radius : int):
	var results = []
	var point = center + CUBIC_DIRECTION[4] * radius
	for i in range(6):
		for j in range(radius):
			results.append(point)
			point = point + CUBIC_DIRECTION[i]
	return results

func cubic_spiral(center : Vector3, radius : int):
	var results = [center]
	for i in range(radius):
		results.append(cubic_ring(center, i))
	return results

func convert_to_int(bits : String):
	var result = 0
	for bit_index in range(bits.length()):
		if (int(bits[bit_index]) == 1):
			result += 2 ** bit_index
	return result
