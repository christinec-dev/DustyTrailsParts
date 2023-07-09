### Main.gd

extends Node2D
	
#transports player to saloon scene
func _on_saloon_body_entered(body):
	if body.name == "Player":
		Global.save()
		Global.change_scene("res://Scenes/Main_2.tscn")
		queue_free()

#saves game every 5 minutes
func _on_timer_timeout():
	if Global.current_scene_name != "MainMenu":
		print("Autosaved game.")
		Global.save()
		
