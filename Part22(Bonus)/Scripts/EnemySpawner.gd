###EnemySpawner.gd

extends Node2D

# tilemap reference so our enemy doesn't spawn on certain layers
var tilemap

#spawn variables that can be edited in Inspector panel
#it’s a rectangle that represents the area in which we want the enemy's to spawn
@export var spawn_area : Rect2 = Rect2(150, 150, 500, 500) 
#max amount of enemies that can spawn
@export var max_enemies = 20
#enemy amount that will load up with the game
@export var existing_enemies = 5
#enemy count, scene ref, and randomizer for enemy spawn position
var enemy_count = 0 
var enemy_scene = load("res://Scenes/Enemy.tscn") #Enemy scene reference
var rng = RandomNumberGenerator.new()

func _ready():
	# Get tilemap node reference in our Main scene
	tilemap = get_tree().root.get_node("Main/Map") 
	#num randomizer
	rng.randomize()
	
	#creates existing enemies on game start
	for i in range(existing_enemies):
		spawn_enemy()
	enemy_count = existing_enemies
	
#valid spawn location checking
func valid_spawn_location(position : Vector2):
	# Check if the cell type in this position is grass or sand, which is a valid location.
	#In our tilemap layer, 0 = water, 1 = sand, 2 = grass, 3 = foliage, etc
	var valid_location = (tilemap.get_layer_name(1)) || (tilemap.get_layer_name(2)) 
	
	# If the two conditions are true, the position is valid
	return valid_location

#enemy spawning		
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	#We have to connect the signal from the enemy script.
	enemy.death.connect(_on_enemy_death)
	
	#spawns enemies on valid locations
	var valid_location = false
	while !valid_location:
		#keep looping to find a valid randomized spawn location on our maps x, y axis 
		enemy.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		enemy.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		#set valid location to be enemies new position
		valid_location = valid_spawn_location(enemy.position)
	
	#spawn enemy with animation delay
	enemy.spawn()
	

#we want to create a new enemy every second, unless the enemy count is already equal to or greater than max_enemies.
func _on_timer_timeout():
	if enemy_count < max_enemies:
		spawn_enemy()
		enemy_count = enemy_count + 1

#decrease the quantity of enemy by one
func _on_enemy_death():
	enemy_count = enemy_count - 1
	#death music
	$DeathMusic.play()	
	
#data to save
func data_to_save():
	var enemies = []
	for enemy in get_children():
		#saves enemy amount, plus their stored health & position values
		if enemy.name.find("Enemy") >= 0:
			enemies.append(enemy.data_to_save())
	return enemies
	
#load data from save file
func data_to_load(data):
	enemy_count = data.size()
	for enemy_data in data:
		var enemy = enemy_scene.instantiate()
		enemy.data_to_load(enemy_data)
		add_child(enemy)
		enemy.get_node("Timer").start()
