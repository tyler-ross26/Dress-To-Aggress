extends Node2D

var last_clicked : String

func _process(delta):
		if Input.is_action_just_pressed("click") and (last_clicked == "Area2D" or  last_clicked == "RigidBody2D"):
			print("click")
		
		
		
func _input(event):
	# Check for left mouse button press
	
	if event is InputEventMouseButton and Input.is_action_just_pressed("click") and event.pressed:
			# Get the mouse position in global (world) coordinates
		var mouse_pos: Vector2 = get_global_mouse_position()
			# Perform a collision query at the mouse position
		var space_state = get_world_2d().direct_space_state
		
		var query = PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_bodies = true  # Adjust as needed
		query.collide_with_areas = true
		
		var results = space_state.intersect_point(query)
			# If any collider was found at this point, print the first one's name
		if results.size() > 0:
			var clicked_object = results[0].collider
			last_clicked = clicked_object.name
			print(last_clicked)
			
			
			
			
			
