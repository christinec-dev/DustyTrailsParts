### Enemy.gd

extends CharacterBody2D

# Enemy movement speed
@export var speed = 50
#it’s the current movement direction of the cactus enemy.
var direction : Vector2
#direction and animation to be updated throughout game state
var new_direction = Vector2(0,1) #only move one spaces
var animation
#attack anim state
var is_attacking = false
# RandomNumberGenerator to generate timer countdown value 
var rng = RandomNumberGenerator.new()
#timer reference to redirect the enemy if collision events occur & timer countdown reaches 0
var timer = 0

#player scene ref
var player

#custom signals
signal death 

#enemy stats
var health = 100
var max_health = 100
var health_regen = 1 

# Bullet & attack variables
var bullet_damage = 50
var bullet_reload_time = 1000
var bullet_fired_time = 0.5
var bullet_scene = preload("res://Scenes/EnemyBullet.tscn")

# Pickup scene
var pickups_scene = preload("res://Scenes/Pickup.tscn")

#When the enemy enters the scene tree, we need to do two things:
#Initialize the Player node reference
#Initialize the random number generator
func _ready():
	player = get_tree().root.get_node("Main/Player")
	rng.randomize()
	
	#reset modulate value so the enemy doesn't stay red
	$AnimationPlayer.current_animation == "[stop]"
	$AnimatedSprite2D.modulate = $AnimatedSprite2D.modulate
	
# Apply movement to the enemy
func _physics_process(delta):
	var movement = speed * direction * delta
	var collision = move_and_collide(movement)

	#if the enemy collides with other objects, turn them around and re-randomize the timer countdown
	if collision != null and collision.get_collider().name != "Player" and collision.get_collider().name != "EnemySpawner" and collision.get_collider().name != "Enemy":
		#direction rotation
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		#timer countdown random range
		timer = rng.randf_range(2, 5)
	#if they collide with the player 
	#trigger the timer's timeout() so that they can chase/move towards our player
	else:
		timer = 0
		
	#plays animations only if the enemy is not attacking
	if !is_attacking:
		enemy_animations(direction)
		
	#resets our attacking state back to false	
	if $AnimatedSprite2D.animation == "spawn":
		$Timer.start()
		
	# Turn RayCast2D toward movement direction	
	if direction != Vector2.ZERO:
		$RayCast2D.target_position = direction.normalized() * 50
			
func _on_timer_timeout():
	# Calculate the distance of the player's relative position to the enemy's position
	var player_distance = player.position - position
	
	#attack radius
	#turn towards player so that it can attack
	if player_distance.length() <= 20:
		direction = Vector2.ZERO
		new_direction = player_distance.normalized()
		$RayCast2D.target_position = direction.normalized() * 50
		
	#chase radius
	#chase/move towards player to attack them
	elif player_distance.length() <= 100 and timer == 0:
		direction = player_distance.normalized()
		
	#random roam radius
	elif timer == 0:
			#this will generate a random direction value
			var random_direction = rng.randf()
			#This direction is obtained by rotating Vector2.DOWN by a random angle between 0 and 2π radians (0 to 360°). 
			if random_direction < 0.05:
				#enemy stops
				direction = Vector2.ZERO
			elif random_direction < 0.1:
				#enemy moves
				direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
				
#animations to play
func enemy_animations(direction : Vector2):
	if direction != Vector2.ZERO:
		new_direction = direction
		animation = "walk_" + returned_direction(new_direction)
		$AnimatedSprite2D.play(animation)
	else:
		animation  = "idle_" + returned_direction(new_direction)
		$AnimatedSprite2D.play(animation)
		
#returns the animation direction
func returned_direction(direction : Vector2):
	var normalized_direction  = direction.normalized()
	if normalized_direction.y >= .7:
		return "down"
	elif normalized_direction.y <= -.7:
		return "up"
	elif normalized_direction.x >= .7:
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x <= -.7:
		$AnimatedSprite2D.flip_h = true
		return "side"
	return ""

#enemy spawn animations
func spawn():
	#creates an animation delay		
	is_attacking = true
	$Timer.start()
	timer = 0
	
func shoot():	
	#checks the current time as the amount of time passed in milliseconds since the engine started
	var now = Time.get_ticks_msec()
		
	#get the collider of the raycast ray
	var target = $RayCast2D.get_collider()
	if target != null:
		#if we are colliding with the player and the player isn't dead
		if target.name == "Player" and player.health > 0:
			#shooting anim
			is_attacking = true
			var animation  = "attack_" + returned_direction(new_direction)
			$AnimatedSprite2D.play(animation)
				
func _process(delta):
	#regenerates our enemy's health
	health = min(health + health_regen * delta, max_health)
	shoot()
				
#will damage the enemy when they get hit
func hit(damage):
	health -= damage
	if health > 0:
		#damage
		$AnimationPlayer.play("damage")
	else:
		#death
		#we play the death animation and
		$AnimatedSprite2D.play("death")
		#stop movement
		$Timer.stop()
		direction = Vector2.ZERO
		#stop health regeneration
		set_process(false)
		#trigger animation finished signal
		is_attacking = true	
		#we emit the signal for the spawner.	
		death.emit()
		
		#drop loot randomly at a 90% chance
		if rng.randf() < 0.9:
			var pickup = pickups_scene.instantiate()
			pickup.item = rng.randi() % 3 #we have three pickups in our enum
			get_tree().root.get_node("Main").call_deferred("add_child", pickup)
			pickup.position = position

#resets our attacking state back to false
func _on_animated_sprite_2d_animation_finished():
		#Once the death animation has played, we can remove the enemy from the scene tree
	if $AnimatedSprite2D.animation == "death":
		get_tree().queue_delete(self)
		
	is_attacking = false
	# Instantiate Bullet
	if $AnimatedSprite2D.animation.begins_with("attack_"):
		var bullet = bullet_scene.instantiate()
		bullet.damage = bullet_damage
		bullet.direction = new_direction.normalized()
		# Place it 4-5 pixels away in front of the player to simulate it coming from the guns barrel
		bullet.position = player.position + new_direction.normalized() * 4
		get_tree().root.get_node("Main").add_child(bullet)
	
#damages the player if player is still in front of enemy
func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation.begins_with("attack_") and $AnimatedSprite2D.frame == 1:
		var target = $RayCast2D.get_collider()
		if target != null:
			if target.name == "Player" and player.health > 0:
				player.hit(bullet_damage)
				
			
	
