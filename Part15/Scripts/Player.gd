### Player.gd

extends CharacterBody2D

#custom signals
signal health_updated
signal stamina_updated
signal ammo_pickups_updated
signal health_pickups_updated
signal stamina_pickups_updated

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
	$AnimationPlayer.stop()
	$AnimationPlayer.current_animation == "[stop]"
	$AnimatedSprite2D.modulate = $AnimatedSprite2D.modulate
	
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
			
	#using stamina consumables		
	elif event.is_action_pressed("ui_consume_stamina"):
		if stamina > 0 && stamina_pickup > 0:
			stamina_pickup = stamina_pickup - 1
			stamina = min(stamina + 50, max_stamina)
			stamina_updated.emit(stamina, max_stamina)		
			stamina_pickups_updated.emit(stamina_pickup)
	
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
	print(health)
	if health > 0:
		#damage
		$AnimationPlayer.play("damage")
		health_updated.emit(health, max_health)
	else:
		#death
		#stop health regeneration
		set_process(false)
		$AnimationPlayer.play("game_over")
