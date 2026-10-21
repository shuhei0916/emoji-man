class_name WantedItem
extends Area2D

## キャラクターの wants と照らし合わせるid
@export var item_id := &"star"


func _on_body_entered(body: Node2D) -> void:
	if body is not EmojiCharacter:
		return
	body.take_item(item_id)
	queue_free()
