extends CanvasLayer

var timer = 0

func _ready() -> void:
	$AnimationPlayer.play("popup")

func _process(delta: float) -> void:
	timer += 1 * delta
	if timer >= 4:
		$AnimationPlayer.play("popdown")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "popdown":
		queue_free()
