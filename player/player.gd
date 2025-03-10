extends CharacterBody2D


const SPEED = 700.0 # 400 for walking
const FRICTION = 0.4 
const ACCELERATION = 0.10

const JUMP_HEIGHT = 600
const JUMP_INCREMENT = 0.25
const JUMP_FALL_GRAVITY = 400
const GRAVITY = 1900

const COYOTE_TIME = 0.1

var vertical_force = JUMP_HEIGHT

var state = "idle"
var is_in_jump = false
var time_since_floor = 100

@onready var anim = $AnimationTree.get("parameters/playback")
@onready var sprite = $Sprite
@onready var main = get_node("/root/main")
@onready var music = get_node("/root/main/music")


@onready var beatblocks = [$sprite, $sprite2, $sprite3, $sprite4]
@onready var camera = $camera

var last_positions = []
const POSITIONS_SIZE = 60
const POSITIONS_LAG_TIME = 0.5

	
@onready var camera_anim = $camera/AnimationPlayer
var selected_bb = 0
var picking_up_item = null

func _ready():

	set_default_beatblocks_pos(false)

	update_beatblocks_pos()
	music.sync_animation.connect(beatblocks_animation)
		
func beatblocks_animation(time):
	prints(time, "called")

func _physics_process(delta):
		
	if main.paused:
		return
		
	
	if Input.is_action_pressed("interact") && can_pickup() && !picking_up_item:
		start_pickup()
	elif Input.is_action_just_released("interact") && picking_up_item:
		end_pickup()
		
	if picking_up_item:
		_physics_process_manage_pickup()
	else:
		_physics_process_movement(delta)
		_physics_process_beatblocks(delta)
	
func _physics_process_beatblocks(delta):
	if self.global_position.distance_to(last_positions[-1]) > 2:
		last_positions.pop_front()
		last_positions.append(self.global_position)
		
		update_beatblocks_pos()
		
func set_default_beatblocks_pos(left=true):
	var pos = []
	for i in range(1, POSITIONS_SIZE):
		if left:
			pos.append(self.global_position - Vector2(12 * (POSITIONS_SIZE - i), 0))
		else:
			pos.append(self.global_position + Vector2(12 * (POSITIONS_SIZE - i), 0))
		
	last_positions = pos
	
	force_update_beatblocks_pos()
	
	
func force_update_beatblocks_pos():
	beatblocks[0].global_position = last_positions[45]
	beatblocks[1].global_position = last_positions[35]
	beatblocks[2].global_position = last_positions[25]
	beatblocks[3].global_position = last_positions[15]
	
func update_beatblocks_pos():
	beatblocks[0].global_position = lerp(beatblocks[0].global_position, last_positions[45], 0.5)
	beatblocks[1].global_position = lerp(beatblocks[1].global_position, last_positions[35], 0.5)
	beatblocks[2].global_position = lerp(beatblocks[2].global_position, last_positions[25], 0.5)
	beatblocks[3].global_position = lerp(beatblocks[3].global_position, last_positions[15], 0.5)
	
	
func _physics_process_movement(delta):
	time_since_floor += delta 
	
		
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
		time_since_floor = 0
		
	if Input.is_action_just_pressed("jump") and time_since_floor < COYOTE_TIME:
		vertical_force = JUMP_HEIGHT
		state = "jump"
		velocity.y = -vertical_force
		
		time_since_floor = 1000
		
	elif velocity.y > 0:
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
	
		

func can_pickup():
	if $pickup_area.get_overlapping_areas().size() == 1:
		if "bb_num" in $pickup_area.get_overlapping_areas()[0]:
			var area = $pickup_area.get_overlapping_areas()[0]
			return area 
	return false
	


func _physics_process_manage_pickup():
	
	if sprite.flip_h:
		if Input.is_action_just_pressed("left"):
			if selected_bb <= 0:
				return 
			selected_bb -= 1
		if Input.is_action_just_pressed("right"):
			if selected_bb >= 3:
				return 
			selected_bb += 1
	else:
		if Input.is_action_just_pressed("right"):
			if selected_bb <= 0:
				return 
			selected_bb -= 1
		if Input.is_action_just_pressed("left"):
			if selected_bb >= 3:
				return 
			selected_bb += 1
		
	picking_up_item.global_position.x = beatblocks[selected_bb].global_position.x
	picking_up_item.global_position.y = beatblocks[selected_bb].global_position.y - 80

func start_pickup():
	picking_up_item = can_pickup()
	selected_bb = 0
	
	picking_up_item.start_pickup()

	# need to change a bit for facing left
	if sprite.flip_h:
		set_default_beatblocks_pos(false)
		camera_anim.play("bb_facingleft")
	else:
		set_default_beatblocks_pos()
		camera_anim.play("bb_facingright")
	
	picking_up_item.global_position.x = beatblocks[0].global_position.x
	picking_up_item.global_position.y = beatblocks[0].global_position.y - 80
	
	
func end_pickup():
	
	# replace the music 
	var old_num = beatblocks[selected_bb].num
	var new_num = picking_up_item.bb_num
	music.replace_block(old_num, new_num)
	
	# replace the sprite in player 
	beatblocks[selected_bb].queue_free() 
	beatblocks[selected_bb] = Data.bb_displays[new_num].instantiate()
	add_child(beatblocks[selected_bb])
	force_update_beatblocks_pos()
	
	# replace the sprite in area2d 
	picking_up_item.display.queue_free() 
	picking_up_item.display = Data.bb_displays[old_num].instantiate()
	picking_up_item.add_child(picking_up_item.display)
	picking_up_item.bb_num = old_num
	
	
	#picking_up_item.global_position = pickup_orig_location
	picking_up_item.end_pickup()
	picking_up_item = null
	
	if sprite.flip_h:
		camera_anim.play_backwards("bb_facingleft")
	else:
		camera_anim.play_backwards("bb_facingright")
	
		
		
