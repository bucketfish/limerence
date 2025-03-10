extends Node2D

@export var num: int = 0
@export var sync_type = SYNC_TYPE.DECO

enum SYNC_TYPE {
	BEATBLOCK,
	DECO
}

var anim: AnimationPlayer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/main/music").sync_animation.connect(play_anim)

	if $anim:
		anim = $anim
		
	if sync_type == SYNC_TYPE.BEATBLOCK:
		self.scale = Vector2(1.5, 1.5)
		
	if anim:
		anim.play("play")
		anim.advance(get_node("/root/main/music").get_current_time())

func play_anim(time, _beatcount):
	if anim:
		anim.stop()
		anim.play("play")
		anim.advance(time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
