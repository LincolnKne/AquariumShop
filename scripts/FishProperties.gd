# FishProperties.gd

extends Node

enum FishRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
	MYTHIC
}

var fish_properties = {
	FishRarity.COMMON: { "time_to_bite": 3, "reel_time": 5, "move_speed": 50, "bounce_distance": 30, "texture": preload("res://assets/sprites/common_mullet.png") },
	FishRarity.UNCOMMON: { "time_to_bite": 5, "reel_time": 7, "move_speed": 60, "bounce_distance": 25, "texture": preload("res://assets/sprites/uncommon_spearfish.png") },
	FishRarity.RARE: { "time_to_bite": 7, "reel_time": 9, "move_speed": 70, "bounce_distance": 20, "texture": preload("res://assets/sprites/rare_dolphin.png") },
	FishRarity.EPIC: { "time_to_bite": 10, "reel_time": 12, "move_speed": 80, "bounce_distance": 15, "texture": preload("res://assets/sprites/epic_squid.png") },
	FishRarity.LEGENDARY: { "time_to_bite": 12, "reel_time": 15, "move_speed": 90, "bounce_distance": 10, "texture": preload("res://assets/sprites/legendary_orca.png") },
	FishRarity.MYTHIC: { "time_to_bite": 15, "reel_time": 18, "move_speed": 100, "bounce_distance": 5, "texture": preload("res://assets/sprites/mythic_bluewhale.png") }
}
