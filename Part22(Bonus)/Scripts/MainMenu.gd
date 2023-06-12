###MainMenu.gd

extends Node2D

#starts a new game
func _on_new_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

#loads a game
func _on_load_pressed():
	#loads main scene
	var game_resource = load("res://Scenes/Main.tscn")
	#instance it so that we can set its loading state to true
	var game = game_resource.instantiate()
	game.loading = true 
	#change the scene to our main scene
	get_tree().root.call_deferred("add_child", game)
	#remove main menu scene
	queue_free()

#quits entire game
func _on_quit_pressed():
	get_tree().quit()
