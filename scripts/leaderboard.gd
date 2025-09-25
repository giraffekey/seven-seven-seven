extends Node

const SAVE_PATH = "res://777-save.tres"
const Save = preload("res://resources/save.gd")

func _ready() -> void:
	var save
	if ResourceLoader.exists(SAVE_PATH):
		save = ResourceLoader.load(SAVE_PATH)
	else:
		save = Save.new()

	var scores = save.scores
	scores.sort_custom(func(a, b): return a.score > b.score)

	for i in range(10):
		var name = get_node("Scores/Name" + str(i))
		var score = get_node("Scores/Score" + str(i))
		if i < len(scores):
			name.text = scores[i].name
			for j in range(10 - len(name.text)):
				name.text += "  "

			score.text = str(scores[i].score)
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
	get_tree().root.add_child(scene)
	queue_free()
