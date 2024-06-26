extends CharacterBody2D

@export var speed: int = 275

func _ready():
	$Sprite.play("Idle")

func _process(delta):
	get_input()
	move_and_animate()

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.y -= speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y += speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x += speed

func move_and_animate():
	if velocity.length() > 0:
		if velocity.x != 0:
			$Sprite.play("Left" if velocity.x < 0 else "Right")
		elif velocity.y != 0:
			$Sprite.play("Up" if velocity.y < 0 else "Down")
	else:
		$Sprite.play("Idle")
	move_and_slide()
