extends Node2D

@export var flipped := false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	if flipped:
		$Sprite2D.flip_h = true
