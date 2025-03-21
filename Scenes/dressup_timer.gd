extends Node2D

@export var dressupTimer: float

func _ready() -> void:
	$Timer.start(dressupTimer)
	
func _process(delta: float) -> void:
	$RichTextLabel.text = str($Timer.time_left).pad_decimals(2)

func _on_timer_timeout() -> void:
	var tree: SceneTree = get_tree()
	tree.change_scene_to_file("res://Scenes/DressUp.tscn") #replace with fighting scene
