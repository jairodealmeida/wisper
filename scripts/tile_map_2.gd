extends TileMap

var noise: FastNoiseLite = FastNoiseLite.new()

func generate_terrain(width: int, height: int, variation: float) -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.2  # Increase frequency for rougher terrain
	noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED  # Use a different fractal type for roughness
	noise.fractal_octaves = 12  # Increase octaves for more detail
	
	var half_width = width / 2
	for x in range(-half_width, half_width + 1):
		for y in range(height):
			var elevation = int(noise.get_noise_2d(x * 0.05, y * 0.1) * variation + height / 2)
			if y < elevation:
				if y > 0 and get_cell_source_id(1, Vector2i(x, y - 1)) == 0:
					set_cell(1, Vector2i(x, y), 0, Vector2i(0, 1))  # Tile solo
				else:
					set_cell(1, Vector2i(x, y), 0, Vector2i(0, 0))  # Tile grama
			else:
				set_cell(1, Vector2i(x, y), 0, Vector2i(1, 0))  # Tile solod

func _ready():
	generate_terrain(80, 7, 3.0)  # Increase variation for rougher terrain
