### Level.gd

extends ColorRect

@onready var value = $Value

func update_level(level):
	value.text = str(level)
