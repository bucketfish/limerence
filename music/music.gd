extends Node2D

# i think we will need quite a bit of music managing. hmmmm.

@onready var sync: AudioStreamSynchronized = $synchronized.stream

var debug_num = 0

var previous_time = 2

signal sync_animation(time)


var currently_playing = [1, 2, 3, 4]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for x in currently_playing:
		sync.set_sync_stream_volume(x, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = get_current_time()
	
	if previous_time > 1 and time < 0.2:
		sync_animation.emit(time, 0)
		
	if previous_time < 3 and time >= 3:
		sync_animation.emit(time, 1)
		
	if previous_time < 6 and time >= 6:
		sync_animation.emit(time, 2)
		
	if previous_time < 9 and time >= 9:
		sync_animation.emit(time, 3)
		
	previous_time = time
	
	
func get_current_time():
	var time = $synchronized.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	return time
	
func replace_block(from_num, to_num):
	sync.set_sync_stream_volume(from_num, -60)
	sync.set_sync_stream_volume(to_num, 0)
