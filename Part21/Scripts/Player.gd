### Player.gd

extends CharacterBody2D

#custom signals
signal health_updated
signal stamina_updated
signal ammo_pickups_updated
signal health_pickups_updated
signal stamina_pickups_updated
signal xp_updated
signal level_updated
signal xp_requirements_updated

# Player movement speed
@export var speed = 50

#direction and animation to be updated throughout game state
var new_direction = Vector2(0,1) #only move one spaces
var animation

#attack anim state
var is_attacking = false

#health and stamina stats
var health = 100
var max_health = 100
var regen_health = 1
var stamina = 100
var max_stamina = 100
var regen_stamina = 5

#pickups
enum Pickups { AMMO, STAMINA, HEALTH }
var ammo_pickup = 12
var health_pickup = 0 
var stamina_pickup = 0 

# Bullet & attack variables
var bullet_damage = 50
var bullet_reload_time = 1000
var bullet_fired_time = 0.5
var bullet_scene = preload("res://Scenes/Bullet.tscn")

#xp and levelling
var xp = 0 
var level = 1 
var xp_requirements = 100

#paused state
var paused

#update it as soon as the children enter the scene
func _ready():
	#initializes the health_updated signal to update the health and max_health values.
	health_updated.emit(health, max_health)
		#initializes the health_updated signal to update the stamina and max_stamina values.
	stamina_updated.emit(stamina, max_stamina)
	
	#initializes the pickups signal to update their values
	ammo_pickups_updated.emit(ammo_pickup)
	health_pickups_updated.emit(health_pickup)
	stamina_pickups_updated.emit(stamina_pickup)
	
	#reset modulate value so the enemy doesn't stay red
	$AnimatedSprite2D.modulate.r = 1
	$AnimatedSprite2D.modulate.g = 1
	$AnimatedSprite2D.modulate.b = 1
	$AnimatedSprite2D.modulate.a = 1
	
	#will connect the signals to the UI components' functions
	health_updated.connect($UI/HealthBar.update_health)
	stamina_updated.connect($UI/StaminaBar.update_stamina)
	ammo_pickups_updated.connect($UI/AmmoAmount.update_ammo_pickup)
	health_pickups_updated.connect($UI/HealthAmount.update_health_pickup)
	stamina_pickups_updated.connect($UI/StaminaAmount.update_stamina_pickup)

	xp_updated.connect($UI/XP.update_xp)
	xp_requirements_updated.connect($UI/XP.update_xp_requirements)	
	level_updated.connect($UI/Level.update_level)
	
	#update ui components to show correct loaded data	
	$UI/AmmoAmount/Value.text = str(ammo_pickup)
	$UI/StaminaAmount/Value.text =  str(stamina_pickup)
	$UI/HealthAmount/Value.text =  str(health_pickup)
	$UI/XP/Value.text =  str(xp)
	$UI/XP/Value2.text =  "/ " + str(xp_requirements)
	$UI/Level/Value.text = str(level)

#updates the stats continously
func _process(delta):
	#regenerates health
	var updated_health = min(health + regen_health * delta, max_health)
	if updated_health != health:
		health = updated_health
		health_updated.emit(health, max_health)
	
	#regenerates stamina	
	var updated_stamina = min(stamina + regen_stamina * delta, max_stamina)
	if updated_stamina != stamina:
		stamina = updated_stamina
		stamina_updated.emit(stamina, max_stamina)

func _physics_process(delta):
	# Get player input (left, right, up/down)
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	#sprinting			
	if Input.is_action_pressed("ui_sprint"):
		while stamina >= 25:
			speed = 100
			stamina = stamina - 5
			stamina_updated.emit(stamina, max_stamina)
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50	
			
	# Apply movement
	var movement = speed * direction * delta

	if !is_attacking:
		# moves our player around, whilst enforcing collisions so that they come to a stop when colliding into other object.
		move_and_collide(movement)
		#plays animations only if the player is not attacking
		player_animations(direction)

	# Check if the attack animation has finished for each frame to prevent the animation frame from clogging
	if is_attacking and !$AnimatedSprite2D.is_playing():
		is_attacking = false	

	# Turn RayCast2D toward movement direction	
	if direction != Vector2.ZERO:
		$RayCast2D.target_position = direction.normalized() * 50			

#animations to play
func player_animations(direction : Vector2):
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation, because we are moving
		animation = "walk_" + returned_direction(new_direction)
		$AnimatedSprite2D.play(animation)
	else:
		#play idle animation, because we are still
		animation  = "idle_" + returned_direction(new_direction)
		$AnimatedSprite2D.play(animation)

#plays attacking animation
func _input(event):
	#input event for our attacking, i.e. our shooting
	if event.is_action_pressed("ui_attack"):
		#checks the current time as the amount of time passed in milliseconds since the engine started
		var now = Time.get_ticks_msec()
	
		#check if player can shoot if the reload time has passed and we have ammo
		if now >= bullet_fired_time and ammo_pickup > 0:		
			#shooting anim
			is_attacking = true
			var animation  = "attack_" + returned_direction(new_direction)
			$AnimatedSprite2D.play(animation)
			
			#shooting sound
			$ShootingMusic.play()
			
			#bullet fired time time to current time
			bullet_fired_time = now + bullet_reload_time
			
			#reduce and signal ammo change
			ammo_pickup = ammo_pickup - 1
			ammo_pickups_updated.emit(ammo_pickup)
		
	#using health consumables
	elif event.is_action_pressed("ui_consume_health"):
		if health > 0 && health_pickup > 0:
			health_pickup = health_pickup - 1
			health = min(health + 50, max_health)
			health_updated.emit(health, max_health)
			health_pickups_updated.emit(health_pickup)
			#play consumable music
			$ConsumableMusic.play()
			
	#using stamina consumables		
	elif event.is_action_pressed("ui_consume_stamina"):
		if stamina > 0 && stamina_pickup > 0:
			stamina_pickup = stamina_pickup - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_updated.emit(stamina, max_stamina)		
			stamina_pickups_updated.emit(stamina_pickup)
			#play consumable music
			$ConsumableMusic.play()
			
	#interact with world		
	elif event.is_action_pressed("ui_interact"):
		var target = $RayCast2D.get_collider()
		if target != null:
			if target.is_in_group("NPC"):
				# Talk to NPC
				target.dialog()
				#play dialog music
				$BackgroundMusic.stop()
				$DialogMusic.play()
				return	
			#go to sleep
			if target.name == "Bed":
				# play sleep screen
				$AnimationPlayer.play("sleeping")
				health = max_health
				stamina = max_stamina
				health_updated.emit(health, max_health)
				stamina_updated.emit(stamina, max_stamina)
				return
				
	#show pause menu
	if !$UI/PauseScreen.visible:
		if event.is_action_pressed("ui_pause"):
			#stop background music
			$BackgroundMusic.stop()
			
			#play pause music
			$PauseMenuMusic.play()		
			
			# if the player is dead, go to back to main menu screen
			if health < 0:
				get_node("/root/Main").queue_free()
				get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
				get_tree().paused = false
				return
			
			#pause game
			get_tree().paused = true
			#show pause screen popup
			$UI/PauseScreen.popup()
			#stops movement processing 	
			set_physics_process(false)
			set_process_input(true)
			#set pauses state to be true
			paused = true
			
#returns the animation direction
func returned_direction(direction : Vector2):
	#it normalizes the direction vector to make sure it has length 1 (1, or -1 up, down, left, and right) 
	var normalized_direction  = direction.normalized()
	
	if normalized_direction.y >= 1:
		return "down"
	elif normalized_direction.y <= -1:
		return "up"
	elif normalized_direction.x >= 1:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x <= -1:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "side"
		
	#default value is empty
	return ""

#resets our attacking state back to false
func _on_animated_sprite_2d_animation_finished():
	
	is_attacking = false
	
	# Instantiate Bullet
	if $AnimatedSprite2D.animation.begins_with("attack_"):
		var bullet = bullet_scene.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		# Place it 4-5 pixels away in front of the player to simulate it coming from the guns barrel
		bullet.position = position + new_direction.normalized() * 4
		get_tree().root.get_node("Main").add_child(bullet)

#add the pickup to our GUI-based inventory
func add_pickup(item):
	#play Pickups Music
	$PickupsMusic.play()
	
	if item == Pickups.AMMO: 
		ammo_pickup = ammo_pickup + 3 # + 3 bullets
		ammo_pickups_updated.emit(ammo_pickup)
	if item == Pickups.HEALTH:
		health_pickup = health_pickup + 1 # + 1 health drink
		health_pickups_updated.emit(health_pickup)
	if item == Pickups.STAMINA:
		stamina_pickup = stamina_pickup + 1 # + 1 stamina drink
		stamina_pickups_updated.emit(stamina_pickup)

#does damage to our player
func hit(damage):
	health -= damage
	health_updated.emit(health, max_health)
	if health > 0:
		#damage
		health_updated.emit(health, max_health)
		$AnimationPlayer.play("damage")
		#play bullet music
		$BulletImpactMusic.play()
	else:
		#death
		#stop health regeneration
		set_process(false)
		#pause game
		set_process_input(true)
		get_tree().paused = true
		$AnimationPlayer.play("game_over")
		#stop background music
		$BackgroundMusic.stop()
		#play game over music
		$GameOverMusic.play()

#updates player xp
func update_xp(value):
	xp += value
	
	#check if player leveled up after reaching xp requirements
	if xp >= xp_requirements:
		#allows input
		set_process_input(true)
		#make popup visible
		$UI/LevelUpPopup.popup_centered()
		$UI/LevelUpPopup.visible = true
		#pause the game
		get_tree().paused = true
		
		#reset xp to 0
		xp = 0
		#increase the level and xp requirements
		level += 1
		xp_requirements *= 2
	
		#update their max health and stamina
		max_health += 10 
		max_stamina += 10 
		
		#give the player some ammo and pickups
		ammo_pickup += 10 
		health_pickup += 5
		stamina_pickup += 3
		
		#update signals for Label values
		health_updated.emit(max_health)
		stamina_updated.emit(max_stamina)
		ammo_pickups_updated.emit(ammo_pickup)
		health_pickups_updated.emit(health_pickup)
		stamina_pickups_updated.emit(stamina_pickup)
		xp_updated.emit(xp)
		
		#reflect changes in Label
		$UI/LevelUpPopup/Message/Rewards/LevelGained.text = "LVL: " + str(level)
		$UI/LevelUpPopup/Message/Rewards/HealthIncreaseGained.text = "+ MAX HP: " + str(max_health)
		$UI/LevelUpPopup/Message/Rewards/StaminaIncreaseGained.text = "+ MAX SP: " + str(max_stamina)
		$UI/LevelUpPopup/Message/Rewards/HealthPickupsGained.text = "+ HEALTH: 5" 
		$UI/LevelUpPopup/Message/Rewards/StaminaPickupsGained.text = "+ STAMINA: 3" 
		$UI/LevelUpPopup/Message/Rewards/AmmoPickupsGained.text = "+ AMMO: 10" 
		
		#stop background music
		$BackgroundMusic.stop()
		
		#play level up music
		$LevelUpMusic.play()
	
	#emit signals
	xp_requirements_updated.emit(xp_requirements)	
	xp_updated.emit(xp)
	level_updated.emit(level)

#resets modulate value
func _on_animation_player_animation_finished(anim_name):
	$AnimatedSprite2D.modulate.r = 1
	$AnimatedSprite2D.modulate.g = 1
	$AnimatedSprite2D.modulate.b = 1
	$AnimatedSprite2D.modulate.a = 1

#level popup confirm
func _on_confirm_pressed():
	$UI/LevelUpPopup.visible =false
	get_tree().paused = false
	$BackgroundMusic.play()
	
#resume game
func _on_resume_pressed():
	if not paused:
		#set pauses state to be false
		get_tree().paused = false
		paused = false
	#accept movement and input
	set_process_input(true)
	set_physics_process(true)
	$UI/PauseScreen.hide()
	#plays background music
	$BackgroundMusic.play()
	#stops pause music
	$PauseMenuMusic.stop()
	
#save game
func _on_save_pressed():
		### I commented mine out because I only want to save my Main scene
	get_node("/root/Main").save()
	print("Game saved successfully")
	
	var current_scene = get_tree().current_scene

#redirect to main menu
func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	get_tree().paused = false
	#stops pause music
	$PauseMenuMusic.stop()

#data to save
func data_to_save():
	return {
		"position" : [position.x, position.y],
		"health" : health,
		"max_health" : max_health,
		"stamina" : stamina,
		"max_stamina" : max_stamina,
		"xp" : xp,
		"xp_requirements" : xp_requirements,
		"level" : level,
		"ammo_pickup" : ammo_pickup,
		"health_pickup" : health_pickup,
		"stamina_pickup" : stamina_pickup
	}
	
#loads data from saved data
func data_to_load(data):
	position = Vector2(data.position[0], data.position[1])
	health = data.health
	max_health = data.max_health
	stamina = data.stamina
	max_stamina = data.max_stamina
	xp = data.xp
	xp_requirements = data.xp_requirements
	level = data.level
	ammo_pickup = data.ammo_pickup
	health_pickup = data.health_pickup
	stamina_pickup = data.stamina_pickup
	
	#update ui components to show correct loaded data	
	$UI/AmmoAmount/Value.text = str(data.ammo_pickup)
	$UI/StaminaAmount/Value.text =  str(data.stamina_pickup)
	$UI/HealthAmount/Value.text =  str(data.health_pickup)
	$UI/XP/Value.text =  str(data.xp)
	$UI/XP/Value2.text =  "/ " + str(data.xp_requirements)
	$UI/Level/Value.text = str(data.level)



