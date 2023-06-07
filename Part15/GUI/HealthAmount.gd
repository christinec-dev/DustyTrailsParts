### HealthAmount.gd

extends ColorRect

@onready var value = $Value

func update_health_pickup(health_pickup):
	value.text = str(health_pickup)
