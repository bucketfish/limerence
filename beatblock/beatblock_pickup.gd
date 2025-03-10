extends Area2D

@export var bb_num = 0


var display = null
var showing = false
var picking_up = false

var orig_location = null

var tween = null
# Called when the node enters the scene tree for the first time.
func _ready():
	display = Data.bb_displays[bb_num].instantiate()
	display.scale = Vector2(1.5, 1.5)
	add_child(display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if !showing && !picking_up:
		$anim.play("show")
	showing = true

func start_pickup():
	orig_location = self.global_position
	picking_up = true
	$anim.play_backwards("show")
	$anim_left.play("left")
	$anim_right.play("right")
	
func end_pickup():
	$anim_left.play_backwards("left")
	$anim_right.play_backwards("right")
	$anim.play("show")
	picking_up = false
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", orig_location, 0.2).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_callback(tween.queue_free)
	


func _on_area_exited(area):
	if showing && !picking_up:
		$anim.play_backwards("show")
	showing = false
