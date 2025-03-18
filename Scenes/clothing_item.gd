extends Node2D

#Loads a wearable resource file into the game as a node

@export_category("Wearable Resource File")
@export var wearable_resource: Wearable

var attackDamageChange: int
var stylePoints: int
var styleMultiplier: float
var speedChange: int

var outfitSet: String
var outfitPattern: String

var idlePose: Texture2D
var walkPose1: Texture2D
var blockPose: Texture2D
var kickPose: Texture2D
var punchPose: Texture2D
var hurtPose: Texture2D
var Pose28: Texture2D

func _ready() -> void:
	attackDamageChange = wearable_resource.get_attack_damage_change()
	stylePoints = wearable_resource.get_style_points()
	styleMultiplier = wearable_resource.get_style_multiplier()
	speedChange = wearable_resource.get_speed_change()
	
	outfitSet = wearable_resource.get_outfit_set()
	outfitPattern = wearable_resource.get_outfit_pattern()
	
	idlePose = wearable_resource.get_idle_pose()
	walkPose1 = wearable_resource.get_walk_pose1();
	blockPose = wearable_resource.get_block_pose();
	kickPose = wearable_resource.get_kick_pose();
	punchPose = wearable_resource.get_punch_pose();
	hurtPose = wearable_resource.get_hurt_pose();
	Pose28 = wearable_resource.get_pose28();
	
	$Sprite2D.set_texture(idlePose)
	$Sprite2D.scale.x = 0.1
	$Sprite2D.scale.y = 0.1
	
func get_wearable_resource() -> Wearable:
	return wearable_resource

func set_idle() -> void:
	$Sprite2D.set_texture(idlePose)
