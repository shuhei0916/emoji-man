extends Node2D

# TODO: NPCが困るきっかけを決めるまでの仮のデバッグ操作。Tキーで NPC が困る
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T:
		$Npc.get_in_trouble()
