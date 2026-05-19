extends CharacterBody2D

@export var speed = 500.0
@export var speed_max = 700.0
@export var gravity = 1200.0
@export var gravity_max = 2700.0
@export var jump_force = 600.0
@export var min_jump = 20.0
@export var desaceleration = 1700.0
var state = "idle"
var dead = false

func _ready():
	velocity = Vector2.ZERO #le da una velocidad inicial de 0

func recoil():
	if $Sprite2D.flip_h == false:
		velocity.x += (30 * speed) / 7
	else:
		velocity.x -= (30 * speed) / 7
	
	
	
func _on_jump_height_timeout():
	if (not Input.is_action_pressed("jump")):
		if (velocity.y < -min_jump):
			velocity.y = -min_jump
	else:
		pass

func animation_controller():
	if $AnimationTree.current_animation != state:
			$AnimationTree.play(state)

#esta funcion es para hacer correcion de esquinas / corner correction
func attempt_correction(amount: int):
	var delta = get_physics_process_delta_time()
	if velocity.y < 0 and test_move(global_transform,
	Vector2(0, velocity.y*delta)):
		for i in range(1, amount*2+1):
			for j in [-1.0, 1.0]:
				if !test_move(global_transform.translated(Vector2(i*j/2, 0)),
				Vector2(0, velocity.y*delta)):
					translate(Vector2(i*j/2, 0))
					if velocity.x * j < 0: velocity.x = 0
					return

func on_death():
	#PlayerStats.death.emit()
	$AnimationTree.stop()
	$snd_death.play()
	$AnimationTree.play("death")
	await $AnimationTree.animation_finished
	#PlayerStats.hp = 100
	#get_tree().reload_current_scene()

func _physics_process(delta):
	
	if dead != true:
		#gravedad
		
		if not is_on_floor():
			$Sprite2D.rotation = 0
			if velocity.y < gravity_max:
				velocity.y += gravity * delta
			if state != "melee" && state != "ouch" && state != "special":
				state = "jump"
				
			
		else:
			
			if velocity.x == 0 && state != "melee" && state != "special":
				state = "stand"
			elif velocity.x != 0 && state != "melee" && state != "special":
				state = "walk"
			
			if Input.is_action_just_pressed("jump") && state != "melee" && state != "special":
				#velocity.y = 0
				velocity.y = -jump_force
				state = "jump"
				$JumpHeight.start()
				#print("salto")
				#$snd_jump.play()
				
			#velocity.y = clamp(velocity.y, gravity, gravity_max)
		
		if state != "melee" && state != "ouch" && state != "special":
	
			if Input.is_action_pressed("left"):
				$Sprite2D.flip_h = true
				$MeleeHitbox/CollisionShape2D.position.x = -15.5
				if velocity.x > 0:
					velocity.x /= 4
				velocity.x -= speed * delta
							
			if Input.is_action_pressed("right"):
				$Sprite2D.flip_h = false
				$MeleeHitbox/CollisionShape2D.position.x = 15.5
				if velocity.x < 0:
					velocity.x /= 4
				velocity.x += speed * delta
		
		if Input.is_action_just_pressed("melee"):
			state = "melee"
		
		if Input.is_action_just_pressed("special"):
			state = "special"
		
		if not Input.is_action_pressed("right") && not Input.is_action_pressed("left") or (state == "melee" or state == "ouch" or state == "special"):
			velocity.x = move_toward(velocity.x, 0, desaceleration * delta)
		
		#evitamos que la velocidad sea demasiado alta
		velocity.x = clamp(velocity.x, -speed_max, speed_max)
		#lo ponemos aca para que sea mas importante y eso
		
		#if PlayerStats.hp <= 0:
			#PlayerStats.hp = 0
			#dead = true	
			#state = "death"
			#$AnimationTree.stop()
			#on_death()
		
		
		
		#esto mueve al jugador cada frame
		#attempt_correction(10) #esto verifica si hay que hacer corner correction
		animation_controller()
	
	else:
		if not is_on_floor():
			$Sprite2D.rotation = 0
			if velocity.y < gravity_max:
				velocity.y += gravity * delta
		velocity.x = move_toward(velocity.x, 0, desaceleration * delta)
		#evitamos que la velocidad sea demasiado alta
		velocity.x = clamp(velocity.x, -speed_max, speed_max)
	
	move_and_slide()
	

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") && dead != true:
		$AnimationTree.play("ouch")
		
		#print(hp)
		if velocity.x < 0:
			velocity.x += 2* speed
		else:
			velocity.x -= 2 * speed
		


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	state = "stand"
