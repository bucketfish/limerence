@tool
extends Node2D

var waiting_to_extend = false

var waiting_beats_left = 1

@onready var audios = [$audio1, $audio2, $audio3, $audio4]
@onready var rise_to = $rise_to
@onready var line = $line

## Number of bars after that the sound will play. 1 = will play starting the next bar.
@export_range(1, 3) var beat_to_wait = 1 :
	set(beat_new):
		beat_to_wait = beat_new
		set_flower_texture(beat_to_wait)
		
@export var type = flower_block_type.APPEAR

var tween: Tween = null
enum flower_block_type {
	APPEAR, RISE
}
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/main/music").sync_animation.connect(extend_block)

func set_flower_texture(beats):
	$Area2D/flower.texture = load("res://world/flower/flower" + str(beats) + ".png")
	$Area2D/inside.texture = load("res://world/flower/inside" + str(beats) + ".png")

func extend_block(time, beatcount):
	if waiting_to_extend && waiting_beats_left <= 1:
		prints("played", time, beatcount)
		waiting_to_extend = false
		$appear.stop()
		$appear.play("appear")
		$appear.advance(0)
		#$appear.advance(fmod(time, 3.0))
		print(fmod(time, 3.0))
		
		audios[beatcount].playing = true
		
		
		if type == flower_block_type.RISE:
			var original_position = $StaticBody2D.global_position
			
			if tween:
				tween.kill()
			tween = create_tween() 
			tween.tween_property($StaticBody2D, "global_position", rise_to.global_position, 3)
			
			await tween.finished
			
			tween.kill()
			tween = create_tween()
			tween.tween_property($StaticBody2D, "global_position", original_position, 0.2)

		
		
		await get_tree().create_timer(1.0).timeout
		set_flower_texture(beat_to_wait)
		
	elif waiting_to_extend:
		waiting_beats_left -= 1
		set_flower_texture(waiting_beats_left)
		
		prints(waiting_beats_left, "remove")
		
		
func _process(delta):
	line.points[0] = $Area2D.global_position - $line.global_position
	line.points[1] = $StaticBody2D.global_position - $line.global_position
	#draw_dashed_line($Area2D.global_position, $StaticBody2D.global_position, "#e896a6", 4)

func _on_area_2d_body_entered(body):
	if !waiting_to_extend:
		waiting_to_extend = true
		waiting_beats_left = beat_to_wait
		$wait.play("waiting")
		prints("waiting", waiting_beats_left)
	
	#
	#await get_tree().create_timer(2.0).timeout 
	#$anim.play("appear")
