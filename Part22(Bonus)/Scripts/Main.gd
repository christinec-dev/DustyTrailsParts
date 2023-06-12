### Main.gd

extends Node2D

#save path
var save_path = "user://dusty_trails_save.json"

#loading state
var loading = false

#transports player to saloon scene
func _on_saloon_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Scenes/Saloon.tscn")

#save function		
func save():
	#data to save
	var data = {
		"player" : $Player.data_to_save(),
		"npc" : $NPC.data_to_save(),
		"enemies" : $EnemySpawner.data_to_save()
	}
	
	#converts dictionary (data) into json
	var json = JSON.new()
	var to_json = json.stringify(data)
	#opens save file for writing
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	#writes to save file
	file.store_line(to_json)
	#close the file
	file.close()

func _ready():
	#load game
	if loading and FileAccess.file_exists(save_path):
		print("Save file found!")
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		#close file
		file.close()
		
		#load data from parsed json
		$Player.data_to_load(data.player)
		$NPC.data_to_load(data.npc)
		$EnemySpawner.data_to_load(data.enemies)
		if($NPC.quest_complete):
			$QuestItem.queue_free()
	else:
		print("Save file not found!")

#saves game every 5 minutes
func _on_timer_timeout():
	print("Autosaved game.")
	save()
	
