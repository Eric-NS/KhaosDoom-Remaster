extends Node2D

@export var espejo := false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	if espejo:
		$Sprite2D.flip_h = true
