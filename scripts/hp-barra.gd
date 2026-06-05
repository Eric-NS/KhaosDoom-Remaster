extends Node2D

var hp : float
var aux1 #verifica la vida del frame anterior
var aux2 = 0 #para el shader
var player
var max_hp

func _ready():
	player = get_parent().get_parent()
	aux1 = player.max_hp
	max_hp = player.max_hp

func _process(delta):

	if player.hp > max_hp/2:
		$ColorRect/AnimationPlayer.play("normal")
	else:
		$ColorRect/AnimationPlayer.play("low")
		if player.hp < max_hp/4:
			$ColorRect/AnimationPlayer.speed_scale = 1.0
		else:
			$ColorRect/AnimationPlayer.speed_scale = 0.5
	if aux1 != player.hp:
		hp = float(player.hp * 4.025) / float(max_hp)
		$ColorRect.scale = Vector2(hp, 5)
		aux1 = player.hp
		#print(hp)
		var mat := $ColorRect.material as ShaderMaterial
		mat.set_shader_parameter("hit_effect", 1.0)
		aux2 = 15
	if aux2 > 0:
		aux2 -= 1
	else:
		var mat := $ColorRect.material as ShaderMaterial
		mat.set_shader_parameter("hit_effect", 0.0)
