extends CharacterBody2D

var dragging = false

signal dragsignal

#dunno what this does
func _ready():
	get_node("dragsignal").dragSignal.connect(_set_drag_pc)
	
#while running, if dragging is true, make object follow mouse position
func _process(delta):
	if dragging:
		var mousePos = get_viewport().get_mouse_position()
		self.position = Vector2(mousePos.x, mousePos.y)
	
#toggle dragging 
func _set_drag_pc():
	dragging != dragging
	
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("dragsignal")
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			emit_signal("dragsignal")
	elif event is InputEventScreenTouch:
		if event.pressed and event.get_index() == 0:
			self.position = event.get_position()
			
			


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.


func _on_dragsignal() -> void:
	pass # Replace with function body.
