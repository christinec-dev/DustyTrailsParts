### ShopKeeper.gd

extends Node2D

var player
enum Pickups { AMMO, STAMINA, HEALTH }

#player reference
func _ready():
	player = get_tree().root.get_node("%s/Player" % Global.current_scene_name)
	$ShopMenu.hide()

#updates coin amount
func _process(_delta):
	$ShopMenu/ColorRect/CoinAmount.text = "Coins: " + str(player.coins)
	
#opens popup and pauses game
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$ShopMenu.show()
		get_tree().paused = true
		set_process_input(true)
		player.set_physics_process(false)

#closes popup and unpauses game
func _on_close_pressed():
	$ShopMenu.hide()
	get_tree().paused = false
	player.set_physics_process(true)
	set_process_input(false)

#purhcases ammo at the cost of $10
func _on_purchase_ammo_pressed():
	if player.coins >= 10:
		player.add_pickup(Pickups.AMMO)
		player.coins -= 10

#purhcases health at the cost of $5	
func _on_purchase_health_pressed():
	if player.coins >= 5:
		player.add_pickup(Pickups.HEALTH)
		player.coins -= 5

#purhcases stamina at the cost of $2
func _on_purchase_stamina_pressed():
	if player.coins >= 2:
		player.add_pickup(Pickups.STAMINA)
		player.coins -= 2

#hides our menu if we're not in the area2d
func _on_area_2d_body_exited(_body):
	$ShopMenu.hide()
	get_tree().paused = false
	player.set_physics_process(true)
	set_process_input(false)
