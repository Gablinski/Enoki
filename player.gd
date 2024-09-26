extends CharacterBody2D


var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
#E@onready var main_menu: Control = $"."

var speed = 77

var player_state
 
var attack_ip = false #I chose this variable name to represent the attack in progress, and shortened it down to ip 
var current_dir = "none"  




func _physics_process(delta):
	enemy_attack()
	attack()
	
	if health <= 0:
		player_alive = false  # Go back to menu or respawn
		health = 0 
		get_tree().change_scene_to_file("res://main_menu.tscn")
		self.queue_free()
	
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
		#if the player presses the left arrow key (or "a" key), then the player will move to the left direction.
		#if the player presses the right arrow key (or "d" key), then the player will move to the right direction. 
		#if the player presses the up arrow key (or "w" key), then the player will move to the up direction. 
		#if the player presses the down arrow key (or "s" key), then the player will move to the down direction. 
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
		#If the player holds the right arrow key and the up arrow key then the player will move in the nw direction
		#If the player holds the left arrow key and the up arrow key then the player will move in the ne direction
		#If the player holds the right arrow key and the down arrow key then the player will move in the sw direction
		#If the player holds the left arrow key and the down arrow key then the player will move in the se direction
		if dir.x > 0.5 and dir.y < -0.5:  
			$sprite.play("ne_walk")
		if dir.x > 0.5 and dir.y > 0.5:  
			$sprite.play("se_walk")
		if dir.x < -0.5 and dir.y > 0.5:  
			$sprite.play("sw-walk")
		if dir.x < -0.5 and dir.y < -0.5:  
			$sprite.play("nw_walk")

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

func attack():
	var dir = current_dir
	
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

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
