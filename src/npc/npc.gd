class_name Npc
extends EmojiCharacter


func _physics_process(delta: float) -> void:
	velocity = Player.compute_velocity(velocity, 0.0, false, is_on_floor(), delta)
	move_and_slide()

