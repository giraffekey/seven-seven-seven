extends Node

const SAVE_PATH = "user://777.save"

var scores = []

func _ready() -> void:
	scores.sort_custom(func(a, b): return a.score > b.score)

	for i in range(10):
		var name = get_node("Scores/Name" + str(i))
		var score = get_node("Scores/Score" + str(i))
		if i < len(scores):
			name.text = scores[i].name
			for j in range(10 - len(name.text)):
				name.text += "  "

			score.text = str(int(scores[i].score))
			for j in range(10 - len(score.text)):
				score.text += "  "

			name.visible = true
			score.visible = true
		else:
			name.visible = false
			score.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_released("confirm"):
		confirm()

func _on_confirm_timer_timeout() -> void:
	confirm()

func confirm() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.scores = scores
	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)
	queue_free()
