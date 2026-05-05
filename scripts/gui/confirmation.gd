extends Control

var reset = false

func _reset() -> void:
	reset = true

func _cancel() -> void:
	if "buttonsDisabled" in get_parent():
		get_parent().buttonsDisabled = false
	queue_free()
