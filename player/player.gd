extends CharacterBody2D


const SPEED = 700.0 # 400 for walking
const FRICTION = 0.4 
const ACCELERATION = 0.10


const JUMP_HEIGHT = 600
const JUMP_INCREMENT = 0.25
const JUMP_FALL_GRAVITY = 400
const GRAVITY = 1900

const PINJOINT_XOFFSET = 20


var vertical_force = JUMP_HEIGHT

var state = "idle"
var is_in_jump = false


@onready var anim = $AnimationTree.get("parameters/playback")
@onready var sprite = $Sprite

var last_positions = []
const POSITIONS_SIZE = 60
const POSITIONS_LAG_TIME = 0.5

func _ready():
	for i in range(1, POSITIONS_SIZE):
		last_positions.append(self.global_position + Vector2(5 * i, 0))

func _physics_process(delta):
	_physics_process_movement(delta)
	_physics_process_beatblocks(delta)
	
func _physics_process_beatblocks(delta):

	if self.global_position.distance_to(last_positions[-1]) > 2:
		last_positions.pop_front()
		last_positions.append(self.global_position)
	
	$sprite.global_position = lerp($sprite.global_position, last_positions[45], 0.5)
	$sprite2.global_position = lerp($sprite2.global_position, last_positions[35], 0.5)
	$sprite3.global_position = lerp($sprite3.global_position, last_positions[25], 0.5)
	$sprite4.global_position = lerp($sprite4.global_position, last_positions[15], 0.5)
	
	
func _physics_process_movement(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		pass 
		
	if Input.is_action_pressed("jump"):
		state = "jump"
		velocity.y = clamp(velocity.y - vertical_force, -1000, 10000000)
		vertical_force *= JUMP_INCREMENT
		
	if Input.is_action_just_released("jump"):
		velocity.y += JUMP_FALL_GRAVITY
		
	if is_on_floor():
		state = "idle"
		vertical_force = JUMP_HEIGHT
		
	if velocity.y > 0:
		state = "fall"
		vertical_force = 0
		
	var direction = Input.get_axis("left", "right")
	
	if direction:
		if state == "idle":
			state = "walk"
		velocity.x = lerp(velocity.x, direction * SPEED, float(FRICTION * delta * 70))
	else:
		velocity.x = lerp(velocity.x, 0.0, float(FRICTION * delta * 70))
		
	velocity.y = clamp(velocity.y + GRAVITY * delta, -1000, 1000)
	
	
	if state == "idle":
		anim.travel("idle")
	elif state == "walk":
		anim.travel("run")
	elif state == "jump":
		anim.travel("jump")
	elif state == "fall":
		anim.travel("fall")
		
	if velocity.x < 0:
		sprite.flip_h = true 
	elif velocity.x > 0:
		sprite.flip_h = false
#		

	move_and_slide()
	
	
