extends CharacterBody2D

var speed = 30  # Adjusted speed for the enemy
var player_chase = false  # Flag to indicate if the enemy is chasing the player
var player = null  # Reference to the player node

var health = 100  # Enemy's health
var player_inattack_zone = false  # Flag to check if the player is in the enemy's attack range

# Reference to the enemy health label
@onready var enemy_health: Label = $"enemy_health"  # Adjust the path as necessary

# Main physics process function that updates every frame
func _physics_process(delta):
	deal_with_damage()  # Check for damage from the player

	# Update enemy health label
	enemy_health.text = str(health)  # Update the health label's text

	# If the enemy is chasing the player
	if player_chase:
		# Move towards the player's position at a set speed
		position += (player.position - position).normalized() * speed * delta

		$AnimatedSprite2D.play("walk")  # Play the walking animation
		
		# Flip the sprite based on the player's position
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true  # Flip sprite to face left
		else:
			$AnimatedSprite2D.flip_h = false  # Flip sprite to face right
	else:
		$AnimatedSprite2D.play("idle")  # Play the idle animation when not chasing

# Function to handle when the player enters the detection area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("slime_killed"):  # Ensure the body can call the method
		player = body  # Set the player variable to the detected body
		player_chase = true  # Start chasing the player

# Function to handle when the player exits the detection area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:  # Ensure we're exiting the same player
		player = null  # Clear the player variable
		player_chase = false  # Stop chasing the player

# Function to handle when the player enters the enemy's attack hitbox
func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):  # Check if the entered body is the player
		player_inattack_zone = true  # Set the flag indicating the player is in attack range

# Function to handle when the player exits the enemy's attack hitbox
func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):  # Check if the exited body is the player
		player_inattack_zone = false  # Clear the attack zone flag

# Function to handle damage to the enemy
func deal_with_damage():
	if player_inattack_zone and global.player_current_attack:  # Check if the player is attacking
		health -= 20  # Reduce health by 20
		print("slime health = ", health)  # Print the current health
		if health <= 0:
			if player and player.has_method("slime_killed"):  # Check if player exists and can call the method
				player.slime_killed()  # Call the method to increment slimes killed
			self.queue_free()  # Remove the enemy from the scene if health reaches zero
