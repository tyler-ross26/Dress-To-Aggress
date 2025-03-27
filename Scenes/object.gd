extends Node

var draggable = false
var is_inside_dropable = false
var body_ref : StaticBody2D
var offset: Vector2
var initialPos: Vector2
var started = false 
var platforms = 0
var stat_box : TextEdit

@export var current_wearable: Wearable # WILL ERROR IF NO WEARABLE PRESENT

func _ready():
	#print(self.name)
	if("randomPants" in self.name):
		set_random_pants_wearable()
	else:
		set_random_shirt_wearable()
	
	get_child(0).modulate = current_wearable.get_color()
	stat_box = get_child(2)
	stat_box.visible = false
	stat_box.text = current_wearable.get_description()
	$Sprite2D.texture = current_wearable.get_mirror_pose()


func get_current_wearable() -> Wearable:
	return current_wearable
	
func set_random_pants_wearable():
	var rng = RandomNumberGenerator.new()
	var path   =  "res://Assets/Resources/"
	var pants = ["bluePants.tres","blueShorts.tres","purplePants.tres","whiteShorts.tres"]
	var rand = rng.randi_range(0,pants.size()-1)
	print(rand)
	current_wearable = load(path + pants[rand])
	
func set_random_shirt_wearable():
	var rng = RandomNumberGenerator.new()
	var path   =  "res://Assets/Resources/"
	var shirts = ["redShirt.tres","whiteShirt.tres","greenShirt.tres","blackShirt.tres"]
	var rand = rng.randi_range(0,shirts.size()-1)
	print(rand)
	current_wearable = load(path + shirts[rand])
	#
#func _process(delta):
	#if not started:
		#get_parent().position =  Vector2(220.0,-160.0)
	#
	#if Input.is_action_just_pressed("click"):
		#started = true
	#
	#if draggable and started:
		#if Input.is_action_just_pressed("click"):
			#initialPos = self.global_position
			#offset = get_viewport().get_mouse_position() - self.global_position
			#global.is_dragging = true;
		#if Input.is_action_pressed("click"):
			#get_parent().position =  Vector2(0.0,0.0)
			#self.global_position = get_viewport().get_mouse_position()  - offset
		#elif Input.is_action_just_released("click"):
			#global.is_dragging = false 
			#var tween = get_tree().create_tween()
			#if is_inside_dropable:
				#get_parent().gravity_scale = 0.0
				#print("is_inside_dropable")
				#print(body_ref.position)
				#print(get_parent().gravity_scale)
				##get_parent().gravity_scale = 0.0
				##get_parent().position =  Vector2(0.0,0.0)
				#tween.tween_property(self, "position", body_ref.position, 0.2).set_ease(Tween.EASE_OUT)
				#
			#else:
				#get_parent().gravity_scale = 1.0
				##tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
			#print(body_ref.position)
			#
			
	
	
func _on_area_2d_mouse_entered():
	if not global.is_dragging:
		draggable = true
		self.scale = Vector2(1.05, 1.05)
		stat_box.visible = true


func _on_area_2d_mouse_exited():
	stat_box = get_child(2)
	if not global.is_dragging:
		draggable = false
		self.scale = Vector2(1, 1)
		stat_box.visible = false


func _on_area_2d_body_entered(body: StaticBody2D):
	
	if (body.is_in_group('dropable') and platforms < 1):
		platforms += 1
		is_inside_dropable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 0.2)
		body_ref = body
		

func _on_area_2d_body_exited(body):
	if body.is_in_group('dropable') and platforms == 1:
		platforms -= 1
		is_inside_dropable = false
		body.modulate  = Color(Color.MEDIUM_PURPLE, 0.0)
		
