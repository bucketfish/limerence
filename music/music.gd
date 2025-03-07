extends Node2D

# i think we will need quite a bit of music managing. hmmmm.

@onready var sync: AudioStreamSynchronized = $synchronized.stream

@onready var bb_test = preload("res://audio/bb3.wav")

@onready var label = $"../Label"

var debug_num = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = "activated sounds: 1"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_pressed("debug"):
		if debug_num == 0:
			sync.set_sync_stream_volume(2, 0)
			
			label.text = "activated sounds: 1, 2"
		elif debug_num == 1:
			sync.set_sync_stream_volume(3, 0)
			
			label.text = "activated sounds: 1, 2, 3"
		elif debug_num == 2:
			sync.set_sync_stream_volume(4, 0)
			
			label.text = "activated sounds: 1, 2, 3, 4"
		elif debug_num == 3:
			sync.set_sync_stream_volume(6, 0)
			sync.set_sync_stream_volume(2, -60)
			
			label.text = "activated sounds: 1, 6, 3, 4"
			
		debug_num += 1
