### MainMenu.gd

extends Node2D

#show cursor
func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
# starts a new game
func _on_new_pressed():
	#make current scene main scene
	Global.change_scene("res://Scenes/Main.tscn")
	# Remove MainMenu scene after the scene change is complete
	queue_free()
	
#load game	
func _on_load_pressed():
	Global.loading = true
	Global.load_game()
	queue_free()
	
#quit game
# quits entire game
func _on_quit_pressed():
	get_tree().quit()
