class_name Hurtbox
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	collision_layer = 1
	collision_mask = 2

#Called when the hurtbox is told that it's been hit
func hit():
	print("I've been hit! Call an ambulance!")
