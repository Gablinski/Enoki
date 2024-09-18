extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var speed = 77
var player_state
var attack_ip = false
var current_dir = "none"  # Initialize to a default value
var last_direction = Vector2.ZERO  # Initialize to a zero vector

var is_spinning = false
var spin_duration = 0.5  # Duration of the spin animation
var spin_timer = 0.0  # Timer to track the spin duration

func _physics_process(delta):
	enemy_attack()
	
	if health <= 0:
		player_alive = false  # Go back to menu or respawn
		health = 0 
		print("player died")
		self.queue_free()
	
	var direction = Input.get_vector("left", "right", "up", "down")
	last_direction = direction  # Update last_direction

	# Update current_dir based on direction
	if direction.x > 0:
		current_dir = "right"
	elif direction.x < 0:
		current_dir = "left"
	elif direction.y > 0:
		current_dir = "down"
	elif direction.y < 0:
		current_dir = "up"
	else:
		current_dir = "none"

	if is_spinning:
		spin_timer += delta
		if spin_timer >= spin_duration:
			is_spinning = false
			spin_timer = 0.0
		else:
			return  # Skip other processing while spinning

	if direction.x == 0 and direction.y == 0 and attack_ip == false:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction * speed
	move_and_slide()
	
	play_anim(direction)

func play_anim(dir):
	if player_state == "idle":  # Basic movement (left right up down)
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
		
		if dir.x > 0.5 and dir.y < -0.5:  # 8 directional movement for movements in between 
			$AnimatedSprite2D.play("ne_walk")
		if dir.x > 0.5 and dir.y > 0.5:  
			$AnimatedSprite2D.play("se_walk")
		if dir.x < -0.5 and dir.y > 0.5:  
			$AnimatedSprite2D.play("sw-walk")
		if dir.x < -0.5 and dir.y < -0.5:  
			$AnimatedSprite2D.play("nw_walk")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health -= 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
	
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true

		is_spinning = true  # Start the spin attack
		$AnimatedSprite2D.play("attack_spin")  # Play the spinning attack animation
		$deal_attack_timer.start()  # Start the attack timer
