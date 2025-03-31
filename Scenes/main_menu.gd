extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/DressUp.tscn")


func _on_settings_pressed() -> void:
	print("Settings pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
