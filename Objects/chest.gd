extends Node2D

var chest_open: bool = false
@onready var chest_sprite: AnimatedSprite2D = $chestSprite
@onready var bubbles_sprite: AnimatedSprite2D = $BubblesSprite


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !chest_open:
		chest_sprite.play("open")
		bubbles_sprite.play("Bubbles")
		chest_open = true
