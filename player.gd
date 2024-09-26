extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
@onready var health_label: Label = $"health"  # Reference to the health label
@onready var score_label: Label = $"score"  # Reference to the score label

var speed = 77

var player_state
var attack_ip = false  # I chose this variable name to represent the attack in progress, and shortened it down to ip for ease of writing it down back into my script
var current_dir = "none"
var score = 0  # Player's score
var slimes_killed = 0  # Counter for killed slimes

# Function to add score
func add_score(amount: int) -> void:
	score += amount  # Increase score by the given amount
	score_label.text = str(score)  # Update the score label

# Function to handle slime killed
func slime_killed():
	slimes_killed += 1  # Increment the killed slime counter
	add_score(10)  # Optionally add to score
	if slimes_killed >= 5:  # Check if 5 slimes have been killed
		get_tree().change_scene_to_file("res://win_menu.tscn")  # Change to win menu scene

# This is the main function that runs every frame to handle player actions and enemy interactions.
# This updates the player's movement, checks for enemy attacks, and manages health of the player.
# If the player’s health reaches zero, it switches to the main menu.
func _physics_process(delta):
	enemy_attack()  # This checks if the enemy is attacking and reduces health if needed
	attack()  # This checks if the player is trying to attack and handle animations

	# Update the health label to reflect current health
	health_label.text = str(health)

	# Check if the player is dead and change the scene if so
	if health <= 0:
		player_alive = false  # Player is not alive anymore
		health = 0 
		get_tree().change_scene_to_file("res://main_menu.tscn")  # Go to the main menu
		self.queue_free()  # Remove the player from the scene
	
	var direction = Input.get_vector("left", "right", "up", "down")

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

	if direction.x == 0 and direction.y == 0 and attack_ip == false:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
	
	velocity = direction * speed
	move_and_slide()
	
	play_anim(direction)

# This is the basic movement for my player, RIGHT, UP, DOWN, LEFT directions
# If the player presses the left arrow key (or "a" key), then the player will move to the left direction.
# If the player presses the right arrow key (or "d" key), then the player will move to the right direction. 
# If the player presses the up arrow key (or "w" key), then the player will move in the up direction. 
# If the player presses the down arrow key (or "s" key), then the player will move in the down direction. 
func play_anim(dir):
	if player_state == "idle" and attack_ip == false:  
		$sprite.play("idle")
	if player_state == "walking":
		if dir.y == -1:
			$sprite.play("n_walk")
		if dir.x == 1:
			$sprite.play("e_walk")
		if dir.y == 1:
			$sprite.play("s-walk")
		if dir.x == -1:
			$sprite.play("w_walk")
		
		# 8 directional movement for movements in between 
		# If the player holds the right arrow key and the up arrow key then the player will move in the nw direction
		# If the player holds the left arrow key and the up arrow key then the player will move in the ne direction
		# If the player holds the right arrow key and the down arrow key then the player will move in the sw direction
		# If the player holds the left arrow key and the down arrow key then the player will move in the se direction
		if dir.x > 0.5 and dir.y < -0.5:  
			$sprite.play("ne_walk")
		if dir.x > 0.5 and dir.y > 0.5:  
			$sprite.play("se_walk")
		if dir.x < -0.5 and dir.y > 0.5:  
			$sprite.play("sw-walk")
		if dir.x < -0.5 and dir.y < -0.5:  
			$sprite.play("nw_walk")

func player():
	pass  # This is a placeholder for any future things related to the player

# Function that runs when an enemy enters the player's hitbox.
# This sets a flag to show that the player is in danger of being attacked.
func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

# Function that runs when an enemy leaves the player's hitbox.
# This updates the flag to indicate the player is no longer in danger.
func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

# Function to handle enemy attacks on the player.
# If the player is in range and the enemy can attack, it reduces health and starts the cooldown.
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health -= 10  # Decreases health by 10
		enemy_attack_cooldown = false  # This sets the cooldown to false
		$attack_cooldown.start()  # This starts the cooldown timer
		print(health)  # Print the current health for debugging

# Function to reset the enemy's attack cooldown after a delay.
# This allows the enemy to attack again after the timer finishes.
# It also checks if the player is trying to attack.
func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
	
	# This checks if the player presses the attack button
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true

# This function allows whoever is playing the game to handle the player's attack based on direction.
# This checks if the player is trying to attack and plays the right animation.
# It also starts a timer to manage the attack duration.
func attack():
	var dir = current_dir
	
	# This updates the player's animations. It makes it so whatever direction that the player 
	# is facing updates the animation corresponding to that direction of button that the player chose to move in with their input.
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		if dir == "right":
			$sprite.flip_h = false
			$sprite.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$sprite.flip_h = true
			$sprite.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$sprite.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$sprite.play("back_attack")
			$deal_attack_timer.start()

# This function makes it so that it resets the attack state after the animation is done.
# This stops the timer and updates the attack status to allow new attacks.
func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
