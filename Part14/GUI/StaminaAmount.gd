### StaminaAmount.gd

extends ColorRect

@onready var value = $Value

func update_stamina_pickup(stamina_pickup):
	value.text = str(stamina_pickup)
