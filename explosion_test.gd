extends TextEdit

var explosion = preload("res://scenes/explosion.tscn")

func _on_button_pressed():
	var new = explosion.instantiate()
	new.global_position = get_parent().get_node("Marker2D").global_position
	new.SIZE = float(text) if float(text) != null else 1.0
	get_parent().add_child(new)
