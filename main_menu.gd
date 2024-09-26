extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Placeholder for initialization code that runs when the scene starts.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass  # Placeholder for any frame-by-frame logic


# Function to handle the start button being pressed
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")  # Change to the world scene when the start button is pressed

# Function to handle the settings button being pressed
func _on_settings_pressed() -> void:
	print("Loser")  # Print a message (this could be replaced with settings logic)


# Function to handle the quit button being pressed
func _on_quit_pressed() -> void:
	get_tree().quit()  # Exit the game when the quit button is pressed
