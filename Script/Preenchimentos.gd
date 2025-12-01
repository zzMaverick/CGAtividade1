extends Node2D

@export var pattern_tex: Texture2D
@export var tiles_x: int = 2
@export var tiles_y: int = 2

var polygons: Array = []

func _ready() -> void:
	randomize()
	_create_polygons()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_randomize_colors()
		queue_redraw()

# Cria os três polígonos
func _create_polygons() -> void:
	polygons.clear()

	# TRIÂNGULO
	polygons.append({
		"pos": Vector2(100, 100),
		"vertices": [Vector2(0,0), Vector2(100,0), Vector2(50,86)],
		"colors": [Color(1,0,0), Color(0,1,0), Color(0,0,1)],
		"line_color": Color(0.6,0.1,0.9),
		"pattern_tint": Color(1,1,1)
	})

	# HEXÁGONO
	polygons.append({
		"pos": Vector2(300, 100),
		"vertices": [Vector2(50,0), Vector2(100,25), Vector2(100,75), Vector2(50,100), Vector2(0,75), Vector2(0,25)],
		"colors": [Color(1,0,0), Color(1,1,0), Color(0,1,0), Color(0,1,1), Color(0,0,1), Color(1,0,1)],
		"line_color": Color(0.6,0.1,0.9),
		"pattern_tint": Color(1,1,1)
	})

	# ESTRELA
	polygons.append({
		"pos": Vector2(500, 100),
		"vertices": [Vector2(50,0), Vector2(60,35), Vector2(100,35), Vector2(65,60),
					 Vector2(75,100), Vector2(50,75), Vector2(25,100), Vector2(35,60),
					 Vector2(0,35), Vector2(40,35)],
		"colors": [Color(1,0,0), Color(1,1,0), Color(0,1,0), Color(0,1,1), Color(0,0,1),
				   Color(1,0,1), Color(1,0.5,0), Color(0.5,0,1), Color(0,1,0.5), Color(1,1,1)],
		"line_color": Color(0.6,0.1,0.9),
		"pattern_tint": Color(1,1,1)
	})

# Gera cores aleatórias
func _randomize_colors() -> void:
	for poly in polygons:
		if typeof(poly) != TYPE_DICTIONARY:
			continue
		poly["line_color"] = Color(randf(), randf(), randf())
		for i in range(len(poly["colors"])):
			poly["colors"][i] = Color(randf(), randf(), randf())
		poly["pattern_tint"] = Color(randf(), randf(), randf())

# Desenha tudo
func _draw() -> void:
	for poly in polygons:
		if typeof(poly) != TYPE_DICTIONARY:
			continue

		var verts = poly["vertices"].duplicate()
		var pos = poly["pos"]

		for i in range(len(verts)):
			verts[i] += pos

		# Contorno
		draw_polyline(verts + [verts[0]], poly["line_color"], 2.0, true)

		# Interpolação por vértice
		if len(poly["colors"]) == len(verts):
			draw_polygon(verts, poly["colors"])

		# Textura tileada
		if pattern_tex:
			_draw_pattern_tiled(verts, pos, poly["pattern_tint"])

# Função para tilear a textura dentro do bounding box do polígono
func _draw_pattern_tiled(vertices: Array, offset: Vector2, tint: Color) -> void:
	var min_x = vertices[0].x
	var min_y = vertices[0].y
	var max_x = vertices[0].x
	var max_y = vertices[0].y

	for v in vertices:
		min_x = min(min_x, v.x)
		min_y = min(min_y, v.y)
		max_x = max(max_x, v.x)
		max_y = max(max_y, v.y)

	var r = Rect2(Vector2(min_x, min_y) + offset, Vector2(max_x - min_x, max_y - min_y))

	# Tiling: repete a textura no retângulo
	var tex_w = pattern_tex.get_width()
	var tex_h = pattern_tex.get_height()
	for y in range(0, int(r.size.y), tex_h):
		for x in range(0, int(r.size.x), tex_w):
			var rect = Rect2(r.position + Vector2(x, y), Vector2(tex_w, tex_h))
			draw_texture_rect(pattern_tex, rect, false, tint)
