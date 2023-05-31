extends CharacterBody2D

# Player movement speed
@export var speed = 50

func _physics_process(delta):
    # Get player input (left, right, up/down)
    var direction: Vector2
    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    
    # If input is digital, normalize it for diagonal movement
    if abs(direction.x) == 1 and abs(direction.y) == 1:
        direction = direction.normalized()
            
    # Apply movement
    var movement = speed * direction * delta
    # moves our player around, whilst enforcing collisions so that they come to a stop when colliding into other object.
    move_and_collide(movement)
    
