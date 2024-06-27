extends Area2D

func _ready():
	print("FishingPromptArea ready")
	connect("body_entered", Callable(self, "_on_FishingPromptArea_body_entered"))
	connect("body_exited", Callable(self, "_on_FishingPromptArea_body_exited"))
	$FishingPromptLabel.visible = false
	$InstructionLabel.visible = false

func _on_FishingPromptArea_body_entered(body):
	print("body entered:", body)
	if body.name == "Player":
		print("Player entered fishing area")
		$FishingPromptLabel.visible = true
		$InstructionLabel.visible = false  # Ensure the instruction label is initially hidden
		body.set_can_fish(true)
		body.fishing_prompt_label = $FishingPromptLabel
		body.instruction_label = $InstructionLabel

func _on_FishingPromptArea_body_exited(body):
	print("body exited:", body)
	if body.name == "Player":
		print("Player exited fishing area")
		$FishingPromptLabel.visible = false
		$InstructionLabel.visible = false
		body.set_can_fish(false)
		body.fishing_prompt_label = null
		body.instruction_label = null
