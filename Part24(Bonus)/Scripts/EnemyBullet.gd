###EnemyBullets.gd
extends Area2D

#bullet variables
var tilemap
var speed = 80
var direction : Vector2
var damage

#initialize tilemap node
func _ready():
	tilemap = get_tree().root.get_node("%s/Map" % Global.current_scene_name)
	
#The position of the bullet  must be recalculated at each frame	
func _process(delta):
	position = position + speed * delta * direction
	
#Collision detection for the bullet	
func _on_body_entered(body):
	# Ignore collision with Enemy
	if body.name == "Enemy":
		return
	
	# Ignore collision with Water
	if body.name == "Map":
		#water == Layer 0
		if tilemap.get_layer_name(0):
				return
	
	# If the bullets hit a enemy, damage them
	if body.name.find("Player") >= 0:
		body.hit(damage)
		
	# Stop the movement and explode
	direction = Vector2.ZERO
	$AnimatedSprite2D.play("impact")

#remove the bullet from the scene
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "impact":
		get_tree().queue_delete(self)

#If the bullet does not hit anything, it will self-destruct in 2 seconds
func _on_timer_timeout():
	$AnimatedSprite2D.play("impact")

