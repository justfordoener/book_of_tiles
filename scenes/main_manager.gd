extends Node

@onready var tile_placement = $TilePlacement
@onready var grid

func toggle_grid() -> void:
	tile_placement.recreate_preview_instance()
