### AmmoAmount.gd

extends ColorRect

@onready var value = $Value

func update_ammo_pickup(ammo_pickup):
	value.text = str(ammo_pickup)
