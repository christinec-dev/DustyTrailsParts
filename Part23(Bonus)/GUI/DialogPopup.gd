####DialogPopup.gd

extends Popup

#gets the values of our npc from our NPC scene and sets it in the label values
var npc_name : set = npc_name_set
var message: set = message_set
var response: set = response_set

#reference to NPC
var npc

#sets the npc name with the value received from NPC
func npc_name_set(new_value):
	npc_name = new_value
	$Dialog/NPC.text = new_value

#sets the message with the value received from NPC
func message_set(new_value):
	message = new_value
	$Dialog/Message.text = new_value
	
#sets the response with the value received from NPC
func response_set(new_value):
	response = new_value
	$Dialog/Response.text = new_value


#opens the dialog
func open():
	get_tree().paused = true
	popup()
	$"../../AnimationPlayer".play("typewriter")
	$"../..".set_physics_process(false)
	
func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_A:	
				npc.dialog("A")
				print("hello")
			elif event.keycode == KEY_B:
				npc.dialog("B")
			
#closes the dialog	
func close():
	get_tree().paused = false
	hide()
	$"../..".set_physics_process(true)
	#play background music
	$"../../BackgroundMusic".play()
	$"../../DialogMusic".stop()
	
	
