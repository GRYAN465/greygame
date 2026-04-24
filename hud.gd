extends CanvasLayer

signal start_game
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GameUI.hide()
	$RulePanel.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout() -> void:
	$Message.hide()
	pass # Replace with function body.

func update_stats(health: int, max_health: int, energy: float, max_energy: int) -> void:
	$GameUI/Bar/HealthBar.max_value = max_health
	$GameUI/Bar/HealthBar.value = health
	$GameUI/Bar/EnergyBar.max_value = max_energy
	$GameUI/Bar/EnergyBar.value = energy
	#print("HP:", health, "/", max_health, " EN:", energy, "/", max_energy)
func update_status_icons(is_burning: bool, is_cold: bool, is_electric: bool, is_wet: bool) -> void:
	$GameUI/VFX/BurnIcon.modulate = Color(1, 1, 1, 1) if is_burning else Color(1, 1, 1, 0)
	$GameUI/VFX/ColdIcon.modulate = Color(1, 1, 1, 1) if is_cold else Color(1, 1, 1, 0)
	$GameUI/VFX/ElecIcon.modulate = Color(1, 1, 1, 1) if is_electric else Color(1, 1, 1, 0)
	$GameUI/VFX/WetIcon.modulate = Color(1, 1, 1, 1) if is_wet else Color(1, 1, 1, 0)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()
	pass # Replace with function body.


func _on_rule_pressed() -> void:
	$RulePanel.show()
	pass # Replace with function body.


func _on_close_pressed() -> void:
	$RulePanel.hide()
	pass # Replace with function body.
