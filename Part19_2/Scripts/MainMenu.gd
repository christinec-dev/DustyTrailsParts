###MainMenu.gd

extends Node2D

#starts a new game
func _on_new_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

#loads a game
func _on_load_pressed():
	pass # Replace with function body.

#quits entire game
func _on_quit_pressed():
	get_tree().quit()
