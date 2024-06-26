extends Area2D

func _on_FishingPromptArea_body_entered(body):
	if body.name == "Player":
		$Label.visible = true
		body.set_can_fish(true)

func _on_FishingPromptArea_body_exited(body):
	if body.name == "Player":
		$Label.visible = false
		body.set_can_fish(false)
