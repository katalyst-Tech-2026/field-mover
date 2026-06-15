extends Node
# Autoload singleton — registered as `GameState` in project.godot.
# Tracks per-run progress and persistent achievements.

signal achievement_unlocked(id: String)

var current_stage: int = 1
var achievements: Dictionary = {}   # { "stage_1_collectible": true, ... }

func unlock(id: String) -> void:
	if achievements.get(id, false):
		return
	achievements[id] = true
	emit_signal("achievement_unlocked", id)

func has(id: String) -> bool:
	return achievements.get(id, false)

func goto_stage(n: int) -> void:
	current_stage = n
	var path := "res://stage_%d.tscn" % n
	# Stage 1 is currently `main.tscn`; map it explicitly.
	if n == 1:
		path = "res://main.tscn"
	get_tree().change_scene_to_file(path)
