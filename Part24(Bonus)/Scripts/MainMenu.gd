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
	# set loading to false as it's a new game
	Global.loading = false
	# Remove MainMenu scene after the scene change is complete
	queue_free()
	
#load game	
func _on_load_pressed():
	Global.loading = true
	if Global.load_game():
		queue_free()
	else:
		Global.loading = false
		print("No game to load.")
	
#quit game
# quits entire game
func _on_quit_pressed():
	get_tree().quit()
