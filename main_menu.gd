extends Control


func _ready() -> void:
	pass  


func _process(delta: float) -> void:
	pass  


# Function when the start button is being pressed
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")  # Changes to the world scene when the start button is pressed

# Function when the settings button is being pressed
func _on_settings_pressed() -> void:
	print("Loser")  


# Function to handle the quit button is being pressed
func _on_quit_pressed() -> void:
	get_tree().quit()  # Exits the game when the quit button is pressed
