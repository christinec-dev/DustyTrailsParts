### Main.gd

extends Node2D

func _ready():
	#will connect the signals to the UI components' functions
	$Player.health_updated.connect($UI/HealthBar.update_health)
	$Player.stamina_updated.connect($UI/StaminaBar.update_stamina)
