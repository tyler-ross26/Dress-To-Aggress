class_name Hitbox
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	collision_layer = 2
	collision_mask = 1
	self.area_entered.connect(on_area_entered)

func on_area_entered(hurtbox: Hurtbox) -> void:
	if hurtbox == null: return
	
	var hurtbox_parent = hurtbox.get_parent()
	var hitbox_parent = get_parent()
	
	if (hitbox_parent == hurtbox_parent): return
	
	if (hitbox_parent.has_method("attack_hit")):
		hitbox_parent.attack_hit(hurtbox_parent)
	
	#Deal damage
	print("Hitbox hit something!")
