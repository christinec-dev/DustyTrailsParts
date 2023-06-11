### Saloon.gd

extends Node2D

#transports player to saloon scene
func _on_saloon_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")


