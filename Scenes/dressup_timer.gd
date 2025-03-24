extends Node2D

@export var dressupTimer: float


var pants_text :String
var shirt_text :String
var file : FileAccess

func _ready() -> void:
	pants_text =  "blueShorts"
	shirt_text = "redShirt"
	file  = FileAccess.open("res://Assets/OutfitSaveFile.txt", FileAccess.READ_WRITE)

	$Timer.start(dressupTimer)
	
func _process(delta: float) -> void:
	$RichTextLabel.text = str($Timer.time_left).pad_decimals(2)

func _on_timer_timeout() -> void:
	var results = get_last_outfit();
	
	if results.size() == 2:
		shirt_text = results[1].collider.get_parent().current_wearable.get_outfit_name()
			
	if results.size() >= 3:
		pants_text = results[1].collider.get_parent().current_wearable.get_outfit_name()	
		shirt_text = results[2].collider.get_parent().current_wearable.get_outfit_name()
		
	file.store_string(pants_text+","+shirt_text+",")
	print(file.get_as_text())
	
	var tree: SceneTree = get_tree()
	tree.change_scene_to_file("res://Scenes/AnimationTesting.tscn") #replace with fighting scene


func get_last_outfit() -> Array[Dictionary]:
	var space_state = get_world_2d().direct_space_state
		
	var query = PhysicsPointQueryParameters2D.new()
	query.position = $"../Platform".position
	query.collide_with_bodies = true  # Adjust as needed
	query.collide_with_areas = true
		
	var results = space_state.intersect_point(query)
	
	return results
	
	
