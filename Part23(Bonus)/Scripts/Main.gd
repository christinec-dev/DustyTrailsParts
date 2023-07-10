### Main.gd

extends Node2D

#connect signal to function	
func _ready():
	Global.scene_changed.connect(_on_scene_changed)
	
#transports player to saloon scene
func _on_saloon_body_entered(body):
	if body.name == "Player":
		Global.change_scene("res://Scenes/Main_2.tscn")

#saves game every 5 minutes
func _on_timer_timeout():
	if Global.current_scene_name != "MainMenu":
		print("Autosaved game.")
		Global.save()

#only after scene has been changed, do we free our resource		
func _on_scene_changed():
	queue_free()
