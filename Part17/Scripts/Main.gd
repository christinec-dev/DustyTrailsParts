### Main.gd

extends Node2D

func _ready():
	#will connect the signals to the UI components' functions
	$Player.health_updated.connect($UI/HealthBar.update_health)
	$Player.stamina_updated.connect($UI/StaminaBar.update_stamina)
	$Player.ammo_pickups_updated.connect($UI/AmmoAmount.update_ammo_pickup)
	$Player.health_pickups_updated.connect($UI/HealthAmount.update_health_pickup)
	$Player.stamina_pickups_updated.connect($UI/StaminaAmount.update_stamina_pickup)

	$Player.xp_updated.connect($UI/XP.update_xp)
	$Player.xp_requirements_updated.connect($UI/XP.update_xp_requirements)	
	$Player.level_updated.connect($UI/Level.update_level)
