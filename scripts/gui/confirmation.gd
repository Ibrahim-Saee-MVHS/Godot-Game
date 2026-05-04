extends Control

var reset = false

func _reset() -> void:
	reset = true

func _cancel() -> void:
	queue_free()
