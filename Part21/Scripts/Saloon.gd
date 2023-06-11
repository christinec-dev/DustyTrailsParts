### Saloon.gd

extends Node2D

#plays different background music
func _ready():
	$Player/BackgroundMusic.stream = load("res://Assets/FX/Music/Free Retro SFX by @inertsongs/Imposter Syndrome (theme).wav")
	$Player/BackgroundMusic.play()
	
#transports player to main scene
func _on_trigger_area_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
