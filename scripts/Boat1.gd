extends CharacterBody2D

@export var speed: float = 150.0
var move_direction: Vector2 = Vector2.ZERO
var player_in_boat: bool = false
var player: Node2D = null

func _physics_process(delta: float) -> void:
	if player_in_boat:
		move_direction = Vector2.ZERO

		if Input.is_action_pressed("ui_right"):
			move_direction.x += 1
		if Input.is_action_pressed("ui_left"):
			move_direction.x -= 1
		if Input.is_action_pressed("ui_down"):
			move_direction.y += 1
		if Input.is_action_pressed("ui_up"):
			move_direction.y -= 1

		move_direction = move_direction.normalized() * speed
		velocity = move_direction
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_body_entered(body):
	if body.name == "Player":
		player = body

func _on_body_exited(body):
	if body.name == "Player":
		player = null

func enter_boat():
	if player:
		player_in_boat = true
		player.hide()  # Hide the player sprite when in the boat
		player.position = self.position  # Move the player to the boat's position

func exit_boat():
	if player:
		player.show()  # Show the player sprite when out of the boat
		player.position = self.position  # Move the player to the boat's position
		player_in_boat = false
		player = null
