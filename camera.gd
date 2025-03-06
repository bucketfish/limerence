extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	var direction = Input.get_axis("left", "right")

	if direction:
		self.offset.x = lerp(self.offset.x, direction * 200, 2 * delta)
	else:
		self.offset.x = lerp(self.offset.x, 0.0, 2 * delta)

	var v_direction = Input.get_axis("up", "down")

	if v_direction:
		self.offset.y = lerp(self.offset.y, v_direction * 200, 4 * delta)
	else:
		self.offset.y = lerp(self.offset.y, 0.0, 4 * delta)
