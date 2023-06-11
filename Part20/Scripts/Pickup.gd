@tool 

extends Area2D

#pickups enum that we export so that we can edit it in Inspector panel
enum Pickups { AMMO, STAMINA, HEALTH }
@export var item : Pickups

#texture assets/resources
var ammo_texture = preload("res://Assets/Icons/shard_01i.png")
var stamina_texture = preload("res://Assets/Icons/potion_02b.png")
var health_texture = preload("res://Assets/Icons/potion_02c.png")

#allow us to change the icon in the editor
func _process(_delta):
	#executes the code in the editor without running the game
	if Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Pickups.AMMO:
			$Sprite2D.set_texture(ammo_texture)
		elif item == Pickups.HEALTH:
			$Sprite2D.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			$Sprite2D.set_texture(stamina_texture)
			
#allow us to change the icon in the editor
func _ready():
	#executes the code in the game
	if not Engine.is_editor_hint():
		#if we choose x item from Inspector dropdown, change the texture
		if item == Pickups.AMMO:
			$Sprite2D.set_texture(ammo_texture)
		elif item == Pickups.HEALTH:
			$Sprite2D.set_texture(health_texture)
		elif item == Pickups.STAMINA:
			$Sprite2D.set_texture(stamina_texture)

#remove pickup from scene and add it to player inventory
func _on_body_entered(body):
	if body.name == "Player":
		body.add_pickup(item)
		#delete from scene tree
		get_tree().queue_delete(self)
