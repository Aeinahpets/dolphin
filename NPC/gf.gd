extends CharacterBody2D

@onready var label: Label = $Label


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("interact") and label.visible:
		play_dialogue()


func play_dialogue():
	DialogueManager.show_dialogue_balloon(load("res://Diologues/talk_to_GF.dialogue"), "first_interaction")

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		label.visible = true


func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		label.visible = false
