### Saloon.gd 
extends Node2D

#go back to Main scene
func _on_trigger_area_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
