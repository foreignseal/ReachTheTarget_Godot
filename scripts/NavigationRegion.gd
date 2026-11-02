extends NavigationRegion2D


func _ready() -> void:
	# Automatically bake navigation polygon around all walls/obstacles on start
	bake_navigation_polygon()

