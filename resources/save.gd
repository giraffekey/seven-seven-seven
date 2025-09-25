class_name Save
extends Resource

@export var scores: Array

func _init(p_scores = []) -> void:
	scores = p_scores

func add_score(name: String, score: int) -> void:
	scores.append({"name": name, "score": score})
