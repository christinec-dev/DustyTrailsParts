###PlayerHouse.gd

extends Node2D

#hide roof when player enters house
func _on_trigger_area_body_entered(body):
	if body.name == "Player":
		$Interior.show()
		$Exterior.hide()
	#prevent enemy from entering our direction
	elif body.name.find("Enemy") >= 0:
		body.direction = -body.direction
		body.timer = 16
		
#show roof when player exists house
func _on_trigger_area_body_exited(body):
	if body.name == "Player":
		$Interior.hide()
		$Exterior.show()
