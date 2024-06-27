extends CharacterBody2D

@export var speed: int = 300
enum FishingState {
	IDLE,
	CASTING,
	WAITING_FOR_BITE,
	REELING,
	CAUGHT
}

var fishing_state = FishingState.IDLE
var is_fishing = false
var can_fish = false
var fishing_prompt_label = null
var instruction_label = null
var input_cooldown = false
var current_fish_rarity

var green_line_speed = 50
var bounce_distance = 30
var reel_duration = 5
var elapsed_reel_time = 0

# Import FishProperties script
const FishProperties = preload("res://scripts/FishProperties.gd")
var fish_properties

var left_red_zone_end
var right_red_zone_start
var green_line

func _ready():
	print("Player ready")
	$Sprite.play("Idle")
	$Sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	fish_properties = FishProperties.new().fish_properties
	
	# Debug: Ensure ReelingBar exists
	var reeling_bar = get_node("../ReelingBar")
	if reeling_bar:
		print("ReelingBar found")
	else:
		print("ReelingBar NOT found")

	# Define the red zones for the bar
	var bar = get_node("../ReelingBar/Bar")
	var bar_width = bar.size.x
	left_red_zone_end = bar_width * 0.18
	right_red_zone_start = bar_width * 0.70

	# Initialize green_line reference
	green_line = get_node("../ReelingBar/Bar/GreenLine")

func _process(delta):
	get_input()
	if is_fishing:
		handle_fishing_input()
	else:
		move_and_animate()
	
	if fishing_state == FishingState.REELING:
		update_reeling_minigame(delta)

func get_input():
	if input_cooldown:
		return
	
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
		if can_fish and not is_fishing:
			print("Starting to fish")
			start_fishing()
		elif is_fishing:
			print("Stopping fishing")
			stop_fishing()
		elif fishing_state == FishingState.CAUGHT:
			hide_fish_sign()

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
	fishing_state = FishingState.IDLE
	$Sprite.play("IdleFishing")
	if fishing_prompt_label:
		fishing_prompt_label.visible = false  # Hide the original label
	if instruction_label:
		instruction_label.text = "Press C to cast or F to stop fishing"
		instruction_label.visible = true  # Show the instruction label
	set_input_cooldown()

func handle_fishing_input():
	if input_cooldown:
		return

	if Input.is_action_just_pressed("ui_cast") and fishing_state == FishingState.IDLE:
		print("Casting the fishing rod")
		cast_fishing_rod()
	elif Input.is_action_just_pressed("ui_fish") and is_fishing:
		print("Stopping fishing")
		stop_fishing()
	elif Input.is_action_just_pressed("mouse_left") and fishing_state == FishingState.REELING:
		green_line.position.x += bounce_distance

func cast_fishing_rod():
	print("Playing Cast animation")
	fishing_state = FishingState.CASTING
	$Sprite.play("Cast")

func _on_animation_finished():
	if $Sprite.animation == "Cast":
		print("Playing CastWait animation")
		fishing_state = FishingState.WAITING_FOR_BITE
		$Sprite.play("CastWait")
		start_bite_timer()

func start_bite_timer():
	current_fish_rarity = randi() % FishProperties.FishRarity.size()
	var bite_time = fish_properties[current_fish_rarity]["time_to_bite"]
	await get_tree().create_timer(bite_time).timeout
	fish_bites()

func fish_bites():
	if fishing_state == FishingState.WAITING_FOR_BITE:
		print("A fish has bitten! Rarity: %s" % current_fish_rarity)
		fishing_state = FishingState.REELING
		start_reeling_minigame()

func start_reeling_minigame():
	var reeling_bar = get_node("../ReelingBar")
	if reeling_bar:
		reeling_bar.visible = true
		bounce_distance = fish_properties[current_fish_rarity]["bounce_distance"]
		green_line_speed = fish_properties[current_fish_rarity]["move_speed"]
		reel_duration = fish_properties[current_fish_rarity]["reel_time"]
		elapsed_reel_time = 0
	else:
		print("Error: ReelingBar node not found")

func update_reeling_minigame(delta):
	elapsed_reel_time += delta
	green_line.position.x -= green_line_speed * delta

	# Check if the green line hits the red zones
	if green_line.position.x <= left_red_zone_end or green_line.position.x >= right_red_zone_start:
		lose_fish()
	
	if elapsed_reel_time >= reel_duration:
		catch_fish()

func lose_fish():
	print("Fish lost")
	reset_reeling_minigame()
	stop_fishing()

func catch_fish():
	print("Fish caught! Rarity: %s" % current_fish_rarity)
	display_caught_fish(current_fish_rarity)
	reset_reeling_minigame()
	reset_fishing()
	# Add logic to add fish to inventory or other game mechanics

func display_caught_fish(rarity):
	fishing_state = FishingState.CAUGHT
	var fish_texture = fish_properties[rarity]["texture"]
	var fish_sign = get_node("/root/FishingScene/FishSign")  # Ensure the correct path
	if fish_sign == null:
		print("Error: FishSign node not found")
		return
	var fish_image = fish_sign.get_node("FishImage")
	if fish_image == null:
		print("Error: FishImage node not found")
		return
	fish_image.texture = fish_texture
	fish_sign.visible = true
	# Create a timer to hide the fish sign after 3 seconds
	var hide_timer = Timer.new()
	hide_timer.wait_time = 3
	hide_timer.one_shot = true
	hide_timer.connect("timeout", Callable(self, "_on_hide_fish_sign_timeout"))
	add_child(hide_timer)
	hide_timer.start()

func _on_hide_fish_sign_timeout():
	hide_fish_sign()

func hide_fish_sign():
	var fish_sign = get_node("/root/FishingScene/FishSign")  # Ensure the correct path
	if fish_sign:
		fish_sign.visible = false
	fishing_state = FishingState.IDLE
	set_input_cooldown()

func reset_reeling_minigame():
	var reeling_bar = get_node("../ReelingBar")
	if reeling_bar:
		reeling_bar.visible = false
	fishing_state = FishingState.IDLE
	elapsed_reel_time = 0
	green_line.position.x = get_node("../ReelingBar/Bar").size.x / 2

func stop_fishing():
	fishing_state = FishingState.IDLE
	is_fishing = false
	$Sprite.play("Idle")
	if instruction_label:
		instruction_label.visible = false  # Hide the instruction label
	if fishing_prompt_label:
		fishing_prompt_label.visible = true  # Show the original label
	set_input_cooldown()

func reset_fishing():
	fishing_state = FishingState.IDLE
	is_fishing = false
	elapsed_reel_time = 0
	if instruction_label:
		instruction_label.visible = false
	if fishing_prompt_label:
		fishing_prompt_label.visible = true

func set_input_cooldown() -> void:
	input_cooldown = true
	await get_tree().create_timer(0.3).timeout
	input_cooldown = false

func set_can_fish(value):
	print("Can fish:", value)
	can_fish = value
