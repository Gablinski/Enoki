extends CharacterBody2D

var speed = 30  # Adjustment of speed for the enemy
var player_chase = false  # This is a flag to indicate if the enemy is chasing the player
var player = null  # This is a reference to the player node

var health = 100  # Variable of the enemy's health
var player_inattack_zone = false  # Flag to check if the player is in the enemy's attack range

# Reference to the enemy health label
@onready var enemy_health: Label = $"enemy_health"  # Adjust the path as necessary

# The main physics process function that updates every frame
func _physics_process(delta):
	deal_with_damage()  # This checks for damage from the player

	# This updates the enemy health bar
	enemy_health.text = str(health)  # Update the health label's text

	# If statement if the enemy is chasing the player
	if player_chase:
		# Move towards the player's position at a set speed
		position += (player.position - position).normalized() * speed * delta

		$AnimatedSprite2D.play("walk")  # Plays the walking animation
		
		# Flip the sprite based on the player's position
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true  # Flips sprite to face left
		else:
			$AnimatedSprite2D.flip_h = false  # Flips sprite to face right
	else:
		$AnimatedSprite2D.play("idle")  # Plays the idle animation when it's not chasing the player

# Function to handle when the player enters the detection area
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("slime_killed"):  
		player = body  
		player_chase = true  

# This function works to handle when the player exits the detection area
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:  
		player = null  
		player_chase = false  

# This function works to handle when the player enters the enemy's attack hitbox
func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):  # Checks if the entered body is the player
		player_inattack_zone = true  

# This function works to handle when the player exits the enemy's attack hitbox
func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):  # Checks if the exited body is the player
		player_inattack_zone = false  

# This function works to handle damage to the enemy
func deal_with_damage():
	if player_inattack_zone and global.player_current_attack:  # Thishecks if the player is attacking
		health -= 20  # Reduces the enemy health by 20
		print("slime health = ", health)  # Prints out the current health
		if health <= 0:
			if player and player.has_method("slime_killed"):  # Thus checks if player exists and can calls the attack
				player.slime_killed()  
			self.queue_free()  # This removes the enemy from the scene if health reaches zero
