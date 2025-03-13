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
	#TODO finish this shit
