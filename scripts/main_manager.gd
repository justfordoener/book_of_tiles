extends Node

@onready var tile_placement = $TilePlacement

func toggle_grid() -> void:
	tile_placement.recreate_preview_instance()
