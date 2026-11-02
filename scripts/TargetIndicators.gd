extends Node2D

# Resources
@export var arrow_texture: Texture2D = preload("res://assets/sprites/arrow.png")
@export var arrow_scale: Vector2 = Vector2(0.3, 0.3)
@export var default_color: Color = Color(0.4559, 0.97, 0.4902, 1.0)
@export var edge_margin: float = 40.0
@export var on_screen_padding: float = 60.0

# Variables
var arrows: Dictionary = {}


func _process(_delta: float) -> void:
	var active_targets: Array[Node] = get_tree().get_nodes_in_group("targets")
	var valid_targets: Array[Node] = []
	
	for node in active_targets:
		if is_instance_valid(node) and not node.get("is_reached"):
			valid_targets.append(node)
	
	var to_remove: Array = []
	for target in arrows.keys():
		if not is_instance_valid(target) or not valid_targets.has(target):
			if is_instance_valid(arrows[target]):
				arrows[target].queue_free()
			to_remove.append(target)
	for target in to_remove:
		arrows.erase(target)
	
	for target in valid_targets:
		if not arrows.has(target):
			var arrow := Sprite2D.new()
			arrow.texture = arrow_texture
			arrow.scale = arrow_scale
			var sprite_node = target.get_node_or_null("Sprite2D")
			if sprite_node and sprite_node is Sprite2D:
				arrow.modulate = sprite_node.modulate
			else:
				arrow.modulate = default_color
			add_child(arrow)
			arrows[target] = arrow
	
	var camera: Camera2D = get_parent() as Camera2D
	var zoom: Vector2 = camera.zoom if camera else Vector2.ONE
	var viewport_size: Vector2 = get_viewport_rect().size / zoom
	var half_size: Vector2 = viewport_size * 0.5
	
	# Update -- Snippet
	for target in valid_targets:
		var arrow: Sprite2D = arrows[target]
		var to_target: Vector2 = target.global_position - global_position
		
		var padding_x: float = on_screen_padding / zoom.x
		var padding_y: float = on_screen_padding / zoom.y
		var on_screen_x: bool = abs(to_target.x) < (half_size.x - padding_x)
		var on_screen_y: bool = abs(to_target.y) < (half_size.y - padding_y)
		
		if on_screen_x and on_screen_y:
			arrow.visible = false
		else:
			arrow.visible = true
			arrow.rotation = to_target.angle() + PI / 2.0
			
			var bounds: Vector2 = half_size - (Vector2(edge_margin, edge_margin) / zoom)
			var scale_x: float = bounds.x / abs(to_target.x) if to_target.x != 0.0 else INF
			var scale_y: float = bounds.y / abs(to_target.y) if to_target.y != 0.0 else INF
			var t: float = min(scale_x, scale_y)
			arrow.position = to_target * t
