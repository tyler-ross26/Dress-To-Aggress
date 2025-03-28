class_name ThrowHitbox
extends Hitbox

func on_area_entered(hurtbox: Hurtbox) -> void:
	var hitbox_parent = get_parent()
	var hurtbox_parent = hurtbox.get_parent()
	if (hitbox_parent == hurtbox_parent):
		hitbox_parent.pose(null)
		return
	
	
	#In hitbox, if opponent is in POSE_STARTUP, call pose_broken(). Else, call my parent's pose() with the target. ELSE, if I don't hit anyone, call pose() with null
	if "state" in hurtbox_parent and (hurtbox_parent.state == 10 or hurtbox_parent.state == 11):
		print("Damn, they broke my pose!")
		hitbox_parent.pose_broken()
		hurtbox_parent.pose_broken()
	elif (hurtbox_parent.has_method("is_on_floor") and hurtbox_parent.is_on_floor()):
		print("Posing! 28")
		print(hurtbox_parent.CharacterState.keys()[hurtbox_parent.state])
		hitbox_parent.pose(hurtbox_parent)
