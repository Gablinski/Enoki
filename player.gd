extends CharacterBody2D

var speed = 77

var player_state



func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x !=  0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction * speed
	move_and_slide()
	
	play_anim(direction)

func play_anim(dir):
	
	if player_state == "idle":  #basic movement (left right up down)
		$AnimatedSprite2D.play("idle")
	if player_state == "walking":
		if dir.y == -1:
			$AnimatedSprite2D.play("n_walk")
		if dir.x == 1:
			$AnimatedSprite2D.play("e_walk")
		if dir.y == 1:
			$AnimatedSprite2D.play("s-walk")
		if dir.x == -1:
			$AnimatedSprite2D.play("w_walk")
		
		if dir.x > 0.5 and dir.y < -0.5: #8 directional movement for movements in between 
			$AnimatedSprite2D.play("ne_walk")
		if dir.x > 0.5 and dir.y > 0.5:  
			$AnimatedSprite2D.play("se_walk")
		if dir.x < -0.5 and dir.y > 0.5:  
			$AnimatedSprite2D.play("sw-walk")
		if dir.x < -0.5 and dir.y < -0.5:  
			$AnimatedSprite2D.play("nw_walk")

func player():
	pass
