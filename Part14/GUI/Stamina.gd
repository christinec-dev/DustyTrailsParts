### Stamina.gd

extends ColorRect

@onready var value = $Value

func update_stamina(stamina, max_stamina):
	value.size.x = 98 * stamina / max_stamina
