extends Node3D
# Moral Choice System - Handles player moral decisions

class_name MoralChoiceSystem

# Signal for when a choice is made
signal moral_choice_made(choice_data: Dictionary)

func _ready():
	print("[MoralChoiceSystem] Initialized")

func present_moral_choice(choice_id: int, description: String, options: Array) -> int:
	"""Present a moral choice to player"""
	print("[MoralChoiceSystem] Presenting choice: %s" % description)
	
	var result = await UIManager.show_moral_choice({
		"id": choice_id,
		"description": description,
		"options": options
	})
	
	return result

func record_choice(choice_type: String, alignment_impact: float, points: int = 0) -> void:
	"""Record moral choice"""
	GameManager.make_moral_choice(choice_type, alignment_impact, points)
	moral_choice_made.emit({
		"type": choice_type,
		"alignment": alignment_impact,
		"points": points
	})

# Common choice scenarios
func mercy_vs_punishment(target_name: String) -> void:
	"""Mercy vs Punishment choice"""
	var options = [
		{"text": "Show Mercy", "alignment": 10, "points": 25},
		{"text": "Punish", "alignment": -10, "points": 10}
	]
	
	var choice = await present_moral_choice(1, "How do you treat %s?" % target_name, options)
	
	if choice == 0:  # Mercy
		record_choice("mercy", 10, 25)
	else:  # Punishment
		record_choice("judgment", -10, 10)

func sacrifice_vs_greed(reward: int) -> void:
	"""Sacrifice vs Greed choice"""
	var options = [
		{"text": "Give to Others", "alignment": 15, "points": 50},
		{"text": "Keep for Yourself", "alignment": -15, "points": 5}
	]
	
	var choice = await present_moral_choice(2, "Share this reward with others?", options)
	
	if choice == 0:  # Sacrifice
		record_choice("sacrifice", 15, 50)
	else:  # Greed
		record_choice("greed", -15, 5)

func truth_vs_deception() -> void:
	"""Truth vs Deception choice"""
	var options = [
		{"text": "Tell Truth", "alignment": 10, "points": 15},
		{"text": "Deceive", "alignment": -20, "points": 0}
	]
	
	var choice = await present_moral_choice(3, "Do you tell the truth?", options)
	
	if choice == 0:  # Truth
		record_choice("honesty", 10, 15)
	else:  # Deception
		record_choice("deception", -20, 0)
