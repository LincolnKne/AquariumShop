extends CharacterBody2D

@export var speed: int = 300
var is_fishing = false
var can_fish = false

func _ready():
	$Sprite.play("Idle")

func _process(delta):
	get_input()
	if is_fishing:
		# Handle fishing input (casting, etc.)
		if Input.is_action_just_pressed("mouse_left"):
			start_casting()
	else:
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

	# Check for fishing input
	if Input.is_action_just_pressed("ui_fish"):
		if can_fish:
			start_fishing()

func move_and_animate():
	if velocity.length() > 0:
		if velocity.x != 0:
			$Sprite.play("Left" if velocity.x < 0 else "Right")
		elif velocity.y != 0:
			$Sprite.play("Up" if velocity.y < 0 else "Down")
	else:
		$Sprite.play("Idle")
	move_and_slide()

func start_fishing():
	is_fishing = true
	$Sprite.play("IdleFishing")

func start_casting() -> void:
	$Sprite.play("Cast")
	await $Sprite.finished
	$Sprite.play("CastWait")

func set_can_fish(value):
	can_fish = value
