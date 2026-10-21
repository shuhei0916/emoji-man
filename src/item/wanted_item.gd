class_name WantedItem
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	body.obtain_wanted_item()
	queue_free()
