extends AnimatedSprite2D


@export var current_wearable: Wearable


@onready
var animation_player: AnimatedSprite2D

func  _ready() -> void:

	animation_player = self
	
	
	self.position  = $"../Body".position
	self.scale = Vector2(3.0,3.0)
	self.modulate = current_wearable.color
	
	animation_player.sprite_frames = SpriteFrames.new()
	createAnimation("idle")
	createAnimation("walk")
	createAnimation("punch")
	createAnimation("kick")
	

func createAnimation(anim_name: String):
	
	animation_player.sprite_frames.add_animation(anim_name)
	if(anim_name == "idle"):
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_idle_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_idle_pose1(), 1.0)
	if(anim_name == "walk"):
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_walk_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_walk_pose1(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_walk_pose2(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_walk_pose3(), 1.0)
	if(anim_name == "punch"):
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_idle_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_punch_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_punch_pose1(), 1.0)
	if(anim_name == "kick"):
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_idle_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_kick_pose0(), 1.0)
		animation_player.sprite_frames.add_frame(anim_name, current_wearable.get_kick_pose1(), 1.0)
	
	animation_player.sprite_frames.set_animation_loop(anim_name, true)
	animation_player.sprite_frames.set_animation_speed(anim_name, 5.0)
	
	


func _physics_process(delta: float):
	if Input.is_action_pressed("Key_S"):
		animation_player.play("kick")
	elif Input.is_action_pressed("Key_A"):
		animation_player.play("walk")
	elif Input.is_action_pressed("Space"):
		animation_player.play("punch")
	else:
		animation_player.play("idle")
	
